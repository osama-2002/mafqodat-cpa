import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_geocoder/fl_geocoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mafqodat/widgets/custom_dropdown_button.dart';
import 'package:mafqodat/widgets/custom_text_field.dart';
import 'package:mafqodat/widgets/location_input.dart';

String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

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
  Color? _selectedColor;
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  String imageUrl = "";
  double? latitude;
  double? longitude;
  double? currentLatitude;
  double? currentLongitude;
  final GlobalKey<LocationInputState> _locationInputKey =
      GlobalKey<LocationInputState>();
  final geocoder = FlGeocoder(googleMapsApiKey);
  String _formattedAddress = '';
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
          title:Text(translate("PickCol")),
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
              child: Text(translate("Select")),
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

  Future<void> _getFormattedAddress() async {
    final coordinates = Location(latitude!, longitude!);
    final results = await geocoder.findAddressesFromLocationCoordinates(
      location: coordinates,
      useDefaultResultTypeFilter: true,
    );

    setState(() {
      _formattedAddress = results[0].formattedAddress!;
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
      _selectedColor = null;
      latitude = currentLatitude;
      longitude = currentLongitude;
    });
  }

  Future<void> _generateNotification() async {
    final db = FirebaseFirestore.instance;

    try {
      final stations = await db.collection('admins').get();
      GeoPoint? nearestStationLocation;
      String? nearestAdminContact;
      double shortestDistance = double.infinity;

      for (QueryDocumentSnapshot<Map<String, dynamic>> station
          in stations.docs) {
        final stationLocation = station['location'] as GeoPoint;
        final adminEmail = station['email'] as String;
        final adminPhoneNumber = station['phoneNumber'] as String;

        final double distance = _calculateDistance(
          latitude!,
          longitude!,
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
        await db.collection('reports_notifications').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'message': 'Thanks for reporting and helping the community!',
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

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _submitReport() async {
    setState(() {
      _isLoading = true;
    });
    final db = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    String reportId = uuid.v4();

    if (_selectedImage != null) {
      String fileName =
          '${reportId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        Reference ref = storage.ref().child('reports/$reportId/$fileName');
        UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
        TaskSnapshot snapshot = await uploadTask;

        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translate("ImageProb"))));
        return;
      }
    }
    await _getFormattedAddress();
    String region;
    if (_formattedAddress.toLowerCase().contains("amman")) {
      region = "amman";
    } else if (_formattedAddress.toLowerCase().contains("zarqa")) {
      region = "zarqa";
    } else {
      region = "other";
    }
    try {
      await db.collection('reports').doc(reportId).set(
        {
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'description': _descriptionController.text,
          'color': _selectedColor!.value,
          'date': _selectedDate,
          'location': GeoPoint(latitude!, longitude!),
          'status': 'pending',
          'type': _selectedDropDownValue,
          'imageUrl': imageUrl,
          'region': region,
        },
      );
      await _generateNotification();
      _clearForm();
      if (mounted) Navigator.of(context).pop();
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
                            labelText: translate("Description"),
                            hintText: translate("DescriptionHint"),
                            prefixIcon: Icons.description_outlined,
                            isUser: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translate("DescriptionHint");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _pickColor(context),
                            child: _selectedColor == null
                                ? Text(translate("PickCol"))
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TimePickerSpinnerPopUp(
                                    mode: CupertinoDatePickerMode.date,
                                    timeWidgetBuilder: (time) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.8),
                                              width: 1.75),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 10, 12, 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              'assets/images/time_picker_calendar_icon.png',
                                              height: 26,
                                              width: 26,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${_selectedDate.day.toString()}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year.toString()}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.normal,
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    initTime: _selectedDate,
                                    minTime: DateTime.now().subtract(
                                      const Duration(days: 30),
                                    ),
                                    maxTime: DateTime.now(),
                                    barrierColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    onChange: (dateTime) {
                                      setState(() {
                                        _selectedDate = DateTime(
                                          dateTime.year,
                                          dateTime.month,
                                          dateTime.day,
                                          _selectedDate.hour,
                                          _selectedDate.minute,
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  TimePickerSpinnerPopUp(
                                    timeWidgetBuilder: (time) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.8),
                                              width: 1.75),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 10, 12, 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              'assets/images/time_picker_clock_icon.png',
                                              height: 26,
                                              width: 26,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.normal,
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    mode: CupertinoDatePickerMode.time,
                                    initTime: _selectedDate,
                                    onChange: (dateTime) {
                                      setState(() {
                                        _selectedDate = DateTime(
                                          _selectedDate.year,
                                          _selectedDate.month,
                                          _selectedDate.day,
                                          dateTime.hour,
                                          dateTime.minute,
                                        );
                                      });
                                    },
                                    barrierColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                  ),
                                ],
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
                                        label: Text(translate("TakePic")),
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
                                      _selectedColor != null &&
                                      _selectedImage != null) {
                                    _submitReport();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            translate("PleaseFill")),
                                      ),
                                    );
                                  }
                                },
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(translate("Submit")),
                              ),
                              const SizedBox(width: 32),
                              ElevatedButton(
                                onPressed: _clearForm,
                                child:Text(translate("Clear")),
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
