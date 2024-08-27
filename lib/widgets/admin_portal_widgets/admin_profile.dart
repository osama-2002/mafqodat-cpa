import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_geocoder/fl_geocoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key, required this.adminData});
  final DocumentSnapshot adminData;

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final geocoder = FlGeocoder(googleMapsApiKey);
  String? formattedAddress = '';
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newPhoneNumberController =
      TextEditingController();

  Future<void> _getFormattedAddress() async {
    final coordinates = Location(
      widget.adminData['location'].latitude,
      widget.adminData['location'].longitude,
    );
    final results = await geocoder.findAddressesFromLocationCoordinates(
      location: coordinates,
      useDefaultResultTypeFilter: true,
    );

    setState(() {
      formattedAddress = results[0].formattedAddress;
    });
  }

  void _showEditInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Update the fields you want to edit. You don't need to fill out all fields.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newNameController,
                decoration: InputDecoration(
                  labelText: " New Display Name",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 0.0,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPhoneNumberController,
                decoration: InputDecoration(
                  labelText: " New Phone Number",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 0.0,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _newNameController.clear();
                _newPhoneNumberController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_newNameController.text.isNotEmpty ||
                    _newPhoneNumberController.text.isNotEmpty) {
                  if (_newNameController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('admins')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update(
                      {
                        'name': _newNameController.text,
                      },
                    );
                  }
                  if (_newPhoneNumberController.text.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('admins')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update(
                      {
                        'phoneNumber': _newPhoneNumberController.text,
                      },
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Close the application and open it again"),
                    ),
                  );
                }
                _newNameController.clear();
                _newPhoneNumberController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getFormattedAddress();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      radius: 40,
                      child: ClipOval(
                        child: Image.asset(
                          widget.adminData['gender'] == 'male'
                              ? 'assets/images/admin_male_avatar.png'
                              : 'assets/images/admin_female_avatar.png',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.adminData['name']}",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Admin",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              LocalizedApp.of(context).delegate.currentLocale.toString() == 'en'
                  ? Positioned(
                      right: 20,
                      top: 20,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _showEditInfoDialog,
                      ),
                    )
                  : Positioned(
                      left: 20,
                      top: 20,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _showEditInfoDialog,
                      ),
                    ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Card(
              elevation: 30,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Location",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "$formattedAddress",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Working Hours",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "9:00 AM - 5:00 PM",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.phone,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Phone",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "+962 ${widget.adminData['phoneNumber']}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.email,
                              color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Email",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${widget.adminData['email']}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
