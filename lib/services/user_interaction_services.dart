import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();
var fireStore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance;

Future<Color?> pickColor(BuildContext context) async {
  Color? selectedColor;

  return await showDialog<Color?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(translate("PickCol")),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            availableColors: const [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.black,
              Colors.white,
              Colors.purple,
              Colors.orange,
              Colors.pink,
              Colors.teal,
              Colors.brown,
              Colors.grey,
            ],
            onColorChanged: (Color color) {
              selectedColor = color;
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(translate("Select")),
            onPressed: () {
              Navigator.of(context).pop(selectedColor);
            },
          ),
        ],
      );
    },
  );
}

Future<File?> takePicture() async {
  final XFile? pickedImage =
      await _picker.pickImage(source: ImageSource.camera);
  return pickedImage != null ? File(pickedImage.path) : null;
}

Future<String> getImageDownloadUrl({
  required File selectedImage,
  required String id,
  required bool isReport,
  required BuildContext context,
}) async {
  String fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  try {
    Reference ref = isReport
        ? storage.ref().child('reports/$id/$fileName')
        : storage.ref().child('items/$id/$fileName');
    UploadTask uploadTask = ref.putFile(selectedImage);
    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(translate("ImageProb"))));
    return "";
  }
}

Future<List<XFile>> selectPictures() async {
  return await _picker.pickMultiImage();
}

Future<List<String>> getImagesDownloadUrls({
  required List<XFile> selectedImages,
  required String id,
  required BuildContext context,
}) async {
  List<String> imageUrls = [];
  for (XFile image in selectedImages) {
    String fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      Reference ref = storage.ref().child('claims/$id/$fileName');
      UploadTask uploadTask = ref.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(translate("ImageProb"))));
      return [];
    }
  }
  return imageUrls;
}
