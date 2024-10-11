import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

FirebaseMessaging messaging = FirebaseMessaging.instance;

void checkNotificationPermission(context) async {
  NotificationSettings settings = await messaging.getNotificationSettings();

  if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    settings = await messaging.requestPermission();
  }

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    _showNotificationPrompt(context);
  }
}

void _showNotificationPrompt(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("EnableNotifications"),
        content: Text(translate("EnableNotificationsMessage")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(translate("Cancel")),
          ),
          TextButton(
            onPressed: () {
              AppSettings.openAppSettings();
              Navigator.pop(context);
            },
            child: Text(translate("Settings")),
          ),
        ],
      );
    },
  );
}

Future<void> saveUserToken(String userId) async {
  String? token = await messaging.getToken();
  if (token != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}

Future<void> checkUserToken(String userId) async {
  String? newToken = await messaging.getToken();
  if (newToken != null) {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    String? existingToken = userDoc['fcmToken'];

    if (existingToken != newToken) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': newToken});
    }
  }
}

Future<Map<String, dynamic>> fetchServiceAccountKey() async {
  String urlString = await FirebaseStorage.instance
      .ref('keys/service_account_key.json')
      .getDownloadURL();

  Uri url = Uri.parse(urlString);

  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load service account key');
  }
}

Future<String> getAccessToken() async {
  var serviceAccountJson = await fetchServiceAccountKey();
  List<String> scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
    'https://www.googleapis.com/auth/cloud-platform',
  ];
  
  final auth.ServiceAccountCredentials credentials =
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
  
  final auth.AccessCredentials accessCredentials = await auth.obtainAccessCredentialsViaServiceAccount(
    credentials,
    scopes,
    http.Client(),
  );

  return accessCredentials.accessToken.data;
}

Future<String?> getUserToken(String userId) async {
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  return userDoc['fcmToken'] as String?;
}

Future<void> sendNotification(String userId, String title, String body) async {
  final String serverAccessTokenKey = await getAccessToken();
  const String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/mafqodat-b14a9/messages:send';
  String? token = await getUserToken(userId);
  
  if (token != null) {
    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverAccessTokenKey',
    };

    final response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.statusCode} ${response.body}');
    }
  } else {
    print('User token not found.');
  }
}
