// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:mafqodat/services/auth_services.dart' as auth_services;
import 'package:mafqodat/services/location_services.dart' as location_services;
import 'package:mafqodat/services/user_interaction_services.dart' as ui_services;
import 'package:mafqodat/services/notification_services.dart' as notification_services;
import 'package:mafqodat/services/ai_services.dart' as ai_services;

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;
Uuid uuid = const Uuid();

Future<void> deleteNotification(String id, String collection) async {
  await firestore.collection(collection).doc(id).delete();
}

Future<void> deleteItem(String id) async {
  var itemFolderContent = await storage.ref('items/$id').listAll();
  itemFolderContent.items.first.delete();
  await deleteMatchesWithId(id, true);
  await firestore.collection('items').doc(id).delete();
}

Future<void> deleteClaim(String id) async {
  var claimFolderContent = await storage.ref('claims/$id').listAll();
  for (var image in claimFolderContent.items) {
    await image.delete();
  }
  await deleteMatchesWithId(id, false);
  await firestore.collection('claims').doc(id).delete();
}

Future<void> deleteReport(String id) async {
  var reportData = await firestore.collection('reports').doc(id).get();
  QuerySnapshot<Map<String, dynamic>> notifications =
      await firestore.collection('reports_notifications').get();
  for (QueryDocumentSnapshot notification in notifications.docs) {
    if (notification['userId'] == reportData['userId']) {
      await firestore
          .collection('reports_notifications')
          .doc(notification.id)
          .delete();
      break;
    }
  }
  var reportFolderContent = await storage.ref('reports/$id').listAll();
  reportFolderContent.items.first.delete();
  await firestore.collection('reports').doc(id).delete();
}

Future<void> closeCase(
  String id,
  BuildContext context,
  VoidCallback onConfirmed,
  VoidCallback onFinished,
) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(translate('AttentionPlease')),
        content: Text(translate('AttentionMessage')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              translate("Cancel"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              onConfirmed();
              var matchData =
                  await firestore.collection('matches').doc(id).get();
              String claimId = matchData['claimId'];
              String itemId = matchData['itemId'];
              await firestore.collection('matches').doc(id).delete();
              await deleteMatchesWithId(claimId, false);
              await deleteMatchesWithId(itemId, true);
              await deleteItem(itemId);
              var claimData = await firestore.collection('claims').doc(claimId).get();
              await deleteClaim(claimId);
              QuerySnapshot<Map<String, dynamic>> notifications =
                  await firestore
                      .collection('matches_notifications')
                      .where('userId', isEqualTo: claimData['userId'])
                      .get();
              for (QueryDocumentSnapshot notification in notifications.docs) {
                firestore
                    .collection('matches_notifications')
                    .doc(notification.id)
                    .delete();
              }
              onFinished();
            },
            child: Text(
              translate("Confirm"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> rejectMatch(String id) async {
  await firestore.collection('matches').doc(id).update(
    {
      'isRejected': true,
    },
  );
}

Future<void> deleteMatchesWithId(String id, bool isItem) async {
  final matches = await firestore.collection('matches').get();
  for (QueryDocumentSnapshot<Map<String, dynamic>> match in matches.docs) {
    if (isItem) {
      if (match['itemId'] == id) {
        await firestore.collection('matches').doc(match.id).delete();
      }
    } else {
      if (match['claimId'] == id) {
        await firestore.collection('matches').doc(match.id).delete();
      }
    }
  }
}

Future<void> generateClaimNotification(
  String id,
  String message,
  String contact,
) async {
  await firestore.collection('claims_notifications').add(
    {
      'userId': id,
      'message': message,
      'timestamp': Timestamp.now(),
      'adminContact': contact,
    },
  );
  notification_services.sendNotification(
      id, translate('notificationTitle'), translate('notificationBody'));
}

Future<void> generateReportNotification(
  double latitude,
  double longitude,
  BuildContext context,
  String imageUrl,
) async {
  try {
    final stations = await firestore.collection('admins').get();
    GeoPoint? nearestStationLocation;
    String? nearestAdminContact;
    double shortestDistance = double.infinity;

    for (QueryDocumentSnapshot<Map<String, dynamic>> station in stations.docs) {
      final stationLocation = station['location'] as GeoPoint;
      final adminEmail = station['email'] as String;
      final adminPhoneNumber = station['phoneNumber'] as String;

      final double distance = location_services.calculateDistance(
        latitude,
        longitude,
        stationLocation.latitude,
        stationLocation.longitude,
      );

      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestStationLocation = stationLocation;
        nearestAdminContact = "$adminEmail\n$adminPhoneNumber";
      }
    }

    if (nearestStationLocation != null && nearestAdminContact != null) {
      await firestore.collection('reports_notifications').add({
        'userId': auth_services.currentUid,
        'message': 'ReportMessage',
        'nearestStationLocation': nearestStationLocation,
        'adminContact': nearestAdminContact,
        'timestamp': Timestamp.now(),
        'imageUrl': imageUrl,
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${translate("NotiProb")} $e")),
    );
  }
}

Future<void> generateMatchNotification(
  GeoPoint location,
  String contact,
  String id,
  String url,
) async {
  await firestore.collection('matches_notifications').add({
    'message': 'MatchFound',
    'location': location,
    'contactInfo': contact,
    'userId': id,
    'timestamp': Timestamp.now(),
    'imageUrl': url,
  });
  notification_services.sendNotification(
      id, translate('notificationTitle'), translate('notificationBody'));
}

Future<void> addItem(
  String type,
  String description,
  File selectedImage,
  int color,
  GeoPoint location,
  BuildContext context,
) async {
  String itemId = uuid.v4();
  String imageUrl = '';

  imageUrl = await ui_services.getImageDownloadUrl(
    selectedImage: selectedImage,
    id: itemId,
    isReport: false,
    context: context,
  );
  try {
    String imageDescription =
          await ai_services.getImageDescription(imageUrl);
    await firestore.collection('items').doc(itemId).set(
      {
        'adminId': auth_services.currentUid,
        'description': description,
        'imageDescription': imageDescription,
        'color': color,
        'date': DateTime.now(),
        'location': location,
        'type': type,
        'imageUrl': imageUrl,
      },
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate("GoodSubmit3")),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${translate("ErrorOc")}$e"),
      ),
    );
  }
}

void submitReport(
  String type,
  String description,
  File selectedImage,
  int color,
  double latitude,
  double longitude,
  DateTime selectedDate,
  BuildContext context,
) async {
  String reportId = uuid.v4();
  String imageUrl = '';
  String formattedAddress = '';

  imageUrl = await ui_services.getImageDownloadUrl(
    selectedImage: selectedImage,
    id: reportId,
    isReport: true,
    context: context,
  );
  formattedAddress =
      await location_services.getFormattedAddress(latitude, longitude);
  String region;
  if (formattedAddress.toLowerCase().contains("amman")) {
    region = "amman";
  } else if (formattedAddress.toLowerCase().contains("zarqa")) {
    region = "zarqa";
  } else {
    region = "other";
  }
  try {
    await firestore.collection('reports').doc(reportId).set(
      {
        'userId': auth_services.currentUid,
        'description': description,
        'color': color,
        'date': selectedDate,
        'location': GeoPoint(latitude, longitude),
        'status': 'pending',
        'type': type,
        'imageUrl': imageUrl,
        'region': region,
      },
    );
    generateReportNotification(latitude, longitude, context, imageUrl);
    //add chatGPT description
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate("GoodSubmit")),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${translate("BadSubmit")} $e"),
      ),
    );
  }
}

void submitClaim(
  String type,
  String description,
  List<XFile> selectedImages,
  int color,
  double latitude,
  double longitude,
  DateTime selectedDate,
  BuildContext context,
) async {
  String claimId = uuid.v4();
  List<String> imageUrls = [];
  List<String> matchedWith = [];
  String formattedAddress = '';
  imageUrls = await ui_services.getImagesDownloadUrls(
    selectedImages: selectedImages,
    id: claimId,
    context: context,
  );
  formattedAddress =
      await location_services.getFormattedAddress(latitude, longitude);
  String region;
  if (formattedAddress.toLowerCase().contains("amman")) {
    region = "amman";
  } else if (formattedAddress.toLowerCase().contains("zarqa")) {
    region = "zarqa";
  } else {
    region = "other";
  }
  try {
    await firestore.collection('claims').doc(claimId).set(
      {
        'userId': auth_services.currentUid,
        'description': description,
        'imagesDescriptions': '',
        'color': color,
        'date': selectedDate,
        'location': GeoPoint(latitude, longitude),
        'status': 'pending',
        'type': type,
        'imageUrls': imageUrls,
        'region': region,
        'matchedWith': matchedWith,
      },
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate("GoodSubmit2")),
      ),
    );
    await firestore.collection('claims').doc(claimId).update({
      'imagesDescriptions': await ai_services.getImagesDescriptions(imageUrls),
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${translate("BadSubmit2")} $e"),
      ),
    );
  }
}

Future<void> reportHandOver(
  var reportData,
  String reportId,
  BuildContext context,
) async {
  final String itemId = uuid.v4();
  final DocumentSnapshot<Map<String, dynamic>> adminData =
      await auth_services.adminData;
  final imageUrl = await ui_services.getNewDownloadUrl(
    reportData['imageUrl'],
    itemId,
  );
  await firestore.collection('items').doc(itemId).set({
    'adminId': auth_services.currentUid,
    'description': reportData['description'],
    'color': reportData['color'],
    'date': DateTime.now(),
    'location': adminData['location'],
    'type': reportData['type'],
    'imageUrl': imageUrl,
  });
  deleteReport(reportId);
  QuerySnapshot<Map<String, dynamic>> notification = await firestore
      .collection('reports_notifications')
      .where('userId', isEqualTo: reportData['userId'])
      .get();
  if (notification.docs.length == 1) {
    firestore
        .collection('reports_notifications')
        .doc(notification.docs.first.id)
        .delete();
  }
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Added to items list')));
}
