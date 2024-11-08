import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mafqodat/services/auth_services.dart' as auth_services;
import 'package:mafqodat/services/location_services.dart' as location_services;

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key, required this.adminData});
  final DocumentSnapshot adminData;

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String? formattedAddress = '';
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newPhoneNumberController = TextEditingController();

  void _showEditInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(translate("Edit")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translate("EditHint"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newNameController,
                decoration: InputDecoration(
                  labelText: translate("NewName"),
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
                  labelText: translate("NewPhoneNo"),
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
                translate("Cancel"),
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
                    await auth_services.updateDisplayName(
                      name: _newNameController.text.trim(),
                      isUser: false,
                    );
                  }
                  if (_newPhoneNumberController.text.isNotEmpty) {
                    await auth_services.updatePhoneNumber(
                      phoneNumber: _newPhoneNumberController.text.trim(),
                      isUser: false,
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(translate("CloseApp")),
                    ),
                  );
                }
                _newNameController.clear();
                _newPhoneNumberController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                translate("Confirm"),
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
    location_services
        .getFormattedAddress(
      widget.adminData['location'].latitude,
      widget.adminData['location'].longitude,
    )
        .then((value) {
      setState(() {
        formattedAddress = value;
      });
    });
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
                        Text(
                          translate("Admin"),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
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
                                Text(
                                  translate("Location"),
                                  style: const TextStyle(
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
                                Text(
                                  translate("WorkingHours"),
                                  style: const TextStyle(
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
                                Text(
                                  translate("PhoneNo"),
                                  style: const TextStyle(
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
                                Text(
                                  translate("Email"),
                                  style: const TextStyle(
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
