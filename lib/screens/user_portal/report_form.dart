import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:mafqodat/widgets/custom_dropdown_button.dart';
import 'package:mafqodat/widgets/custom_text_field.dart';
import 'package:mafqodat/widgets/location_input.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  String? _selectedDropDownValue;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Color? _currentColor;
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  double? latitude;
  double? longitude;
  double? currentLatitude;
  double? currentLongitude;
  final GlobalKey<LocationInputState> _locationInputKey =
      GlobalKey<LocationInputState>();
  Uuid uuid = const Uuid();
  bool _isLoading = false;

  void _unfocusTextFields() {
    _focusScopeNode.unfocus();
  }

  void _onDropdownValueChanged(String? newValue) {
    setState(() {
      _selectedDropDownValue = newValue;
    });
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a primary color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _currentColor,
              availableColors: const [
                Colors.red,
                Colors.blue,
                Colors.yellow,
                Colors.green,
                Colors.purple,
                Colors.white,
                Colors.orange,
                Colors.black,
              ],
              onColorChanged: (Color color) {
                setState(() {
                  _currentColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _takePicture() async {
    final pickedImage =
        await _picker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  void _onCurrentLocationLoaded(
      double currentLatitude, double currentLongitude) {
    setState(() {
      this.currentLatitude = currentLatitude;
      this.currentLongitude = currentLongitude;
    });
  }

  void _onLocationChanged(double latitude, double longitude) {
    setState(() {
      this.latitude = latitude;
      this.longitude = longitude;
    });
  }

  void _clearForm() {
    _locationInputKey.currentState?.refreshLocation();
    setState(() {
      _formKey.currentState!.reset();
      _selectedDropDownValue = null;
      _descriptionController.clear();
      _selectedDate = DateTime.now();
      _selectedImage = null;
      _currentColor = null;
      latitude = currentLatitude;
      longitude = currentLongitude;
    });
  }

  void _submitReport() async {
    setState(() {
      _isLoading = true;
    });
    final db = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    String reportId = uuid.v4();
    String downloadUrl = "";

    if (_selectedImage != null) {
      String fileName =
          '${reportId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        Reference ref = storage.ref().child('reports/$reportId/$fileName');
        UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
        TaskSnapshot snapshot = await uploadTask;

        downloadUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload images')));
        return;
      }
    }
    try {
      await db.collection('reports').doc(reportId).set(
        {
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'description': _descriptionController.text,
          'color': _currentColor!.value,
          'date': _selectedDate,
          'location': GeoPoint(latitude!, longitude!),
          'status': 'pending',
          'type': _selectedDropDownValue,
          'imageUrl': downloadUrl,
        },
      );
      _clearForm();
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusTextFields,
      child: Scaffold(
        appBar: AppBar(
          title: Text(translate("appName")),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: FocusScope(
          node: _focusScopeNode,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                color: Colors.white,
                borderOnForeground: false,
                elevation: 30,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomDropdownButton(
                            controller: _searchController,
                            selectedDropDownValue: _selectedDropDownValue,
                            onChanged: _onDropdownValueChanged,
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _descriptionController,
                            labelText: 'Description',
                            hintText: 'describe what have you lost',
                            prefixIcon: Icons.description_outlined,
                            isUser: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _pickColor(context),
                            child: _currentColor == null
                                ? const Text('Pick a Color')
                                : Icon(
                                    Symbols.colors,
                                    color: _currentColor,
                                    size: 34,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: SizedBox(
                              height: 100,
                              child: ScrollDatePicker(
                                selectedDate: _selectedDate,
                                locale: LocalizedApp.of(context)
                                    .delegate
                                    .currentLocale,
                                onDateTimeChanged: (DateTime value) {
                                  setState(() {
                                    _selectedDate = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: SizedBox(
                              height: 200,
                              child: LocationInput(
                                key: _locationInputKey,
                                onLoaded: _onCurrentLocationLoaded,
                                onChanged: _onLocationChanged,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: SizedBox(
                              height: 200,
                              child: Center(
                                child: _selectedImage != null
                                    ? Image.file(
                                        File(_selectedImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 300,
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () {
                                          _takePicture();
                                        },
                                        icon: const Icon(Icons.camera),
                                        label: const Text('Take a picture'),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      _selectedDropDownValue != null &&
                                      _selectedImage != null) {
                                    _submitReport();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please fill the required fields'),
                                      ),
                                    );
                                  }
                                },
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('Submit'),
                              ),
                              const SizedBox(width: 32),
                              ElevatedButton(
                                onPressed: _clearForm,
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
