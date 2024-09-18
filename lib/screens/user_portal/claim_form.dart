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
import 'package:fl_geocoder/fl_geocoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mafqodat/widgets/custom_dropdown_button.dart';
import 'package:mafqodat/widgets/custom_text_field.dart';
import 'package:mafqodat/widgets/location_input.dart';

String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

class ClaimForm extends StatefulWidget {
  const ClaimForm({super.key});

  @override
  State<ClaimForm> createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  String? _selectedDropDownValue;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  Color? _selectedColor;
  List<XFile>? _selectedImages;
  double? latitude;
  double? longitude;
  double? currentLatitude;
  double? currentLongitude;
  final GlobalKey<LocationInputState> _locationInputKey = GlobalKey<LocationInputState>();
  final geocoder = FlGeocoder(googleMapsApiKey);
  String formattedAddress = '';
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
              pickerColor: _selectedColor,
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
                setState(() {
                  _selectedColor = color;
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

  Future<void> _getFormattedAddress() async {
    final coordinates = Location(latitude!, longitude!);
    final results = await geocoder.findAddressesFromLocationCoordinates(
      location: coordinates,
      useDefaultResultTypeFilter: true,
    );

    setState(() {
      formattedAddress = results[0].formattedAddress!;
    });
  }

  void _clearForm() {
    _locationInputKey.currentState?.refreshLocation();
    setState(() {
      _formKey.currentState!.reset();
      _selectedDropDownValue = null;
      _descriptionController.clear();
      _selectedDate = DateTime.now();
      _selectedImages = [];
      _selectedColor = null;
      latitude = currentLatitude;
      longitude = currentLongitude;
    });
  }

  void _submitClaim() async {
    setState(() {
      _isLoading = true;
    });
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
    await _getFormattedAddress();
    String region;
    if (formattedAddress.toLowerCase().contains("amman")) {
      region = "amman";
    } else if (formattedAddress.toLowerCase().contains("zarqa")) {
      region = "zarqa";
    } else {
      region = "other";
    }
    try {
      await db.collection('claims').doc(claimId).set(
        {
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'description': _descriptionController.text,
          'color': _selectedColor!.value,
          'date': _selectedDate,
          'location': GeoPoint(latitude!, longitude!),
          'status': 'pending',
          'type': _selectedDropDownValue,
          'imageUrls': imageUrls,
          'region': region,
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                            child: _selectedColor == null
                                ? const Text('Pick a Color')
                                : Icon(
                                    Symbols.colors,
                                    color: _selectedColor,
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
                                      _selectedDropDownValue != null &&
                                      _selectedColor != null) {
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
