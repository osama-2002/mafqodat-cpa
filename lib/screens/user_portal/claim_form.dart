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

class ClaimForm extends StatefulWidget {
  const ClaimForm({super.key});

  @override
  State<ClaimForm> createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  String? selectedValue;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  Color? _currentColor;
  List<XFile>? _selectedImages;
  double? latitude;
  double? longitude;
  double? currentLatitude;
  double? currentLongitude;
  final GlobalKey<LocationInputState> _locationInputKey =
      GlobalKey<LocationInputState>();
  Uuid uuid = const Uuid();

  void _unfocusTextFields() {
    _focusScopeNode.unfocus();
  }

  void _onDropdownValueChanged(String? newValue) {
    setState(() {
      selectedValue = newValue;
    });
  }

  Future<void> _selectImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();
      setState(() {
        _selectedImages = selectedImages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred, try again later')));
    }
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
      selectedValue = null;
      _descriptionController.clear();
      _selectedDate = DateTime.now();
      _selectedImages = [];
      _currentColor = null;
      latitude = currentLatitude;
      longitude = currentLongitude;
    });
  }

  void _submitClaim() async {
    final db = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    String claimId = uuid.v4();

    List<String> imageUrls = [];
    if (_selectedImages != null) {
      for (XFile image in _selectedImages!) {
        String fileName =
            '${claimId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        try {
          Reference ref = storage.ref().child('claims/$claimId/$fileName');
          UploadTask uploadTask = ref.putFile(File(image.path));
          TaskSnapshot snapshot = await uploadTask;

          String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload images')));
          return;
        }
      }
    }
    try {
      await db.collection('claims').doc(claimId).set(
        {
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'description': _descriptionController.text,
          'color': _currentColor!.value,
          'date': _selectedDate,
          'location': GeoPoint(latitude!, longitude!),
          'status': 'pending',
          'type': selectedValue,
          'imageUrls': imageUrls,
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
          content: Text('Failed to submit claim: $e'),
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
                            selectedValue: selectedValue,
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
                                child: _selectedImages != null &&
                                        _selectedImages!.isNotEmpty
                                    ? PageView.builder(
                                        itemCount: _selectedImages!.length,
                                        itemBuilder: (context, index) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.file(
                                              File(
                                                  _selectedImages![index].path),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 200,
                                            ),
                                          );
                                        },
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: _selectImages,
                                        icon: const Icon(Icons.photo),
                                        label:
                                            const Text('Choose from gallery'),
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
                                      selectedValue != null) {
                                    _submitClaim();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please fill the required fields'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Submit'),
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
