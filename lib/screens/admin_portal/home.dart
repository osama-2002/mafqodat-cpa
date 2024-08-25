import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:mafqodat/screens/admin_portal/history.dart';
import 'package:mafqodat/widgets/admin_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  DocumentSnapshot? adminData;

  void _getAdminData() async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection('admins')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      adminData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getAdminData();
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translate("bismillah"),
            style: const TextStyle(
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (_currentIndex == 1) {
      activePage = const ClaimsAndReports();
    }
    if (_currentIndex == 2) {
      activePage = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Possible Matches",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      );
    }
    if (_currentIndex == 3) {
      activePage = AdminProfile(adminData: adminData!);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("appName")),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                      "Are you sure you want to sign out?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: activePage,
      drawer: Drawer(
        child: IconButton(
          onPressed: () {
            if (LocalizedApp.of(context).delegate.currentLocale.toString() ==
                'en') {
              changeLocale(context, 'ar');
            } else {
              changeLocale(context, 'en');
            }
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.translate),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.search),
            title: const Text("Items"),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Symbols.person_alert),
            title: const Text("Claims"),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.library_add_check_outlined),
            title: const Text("Matches"),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(
                Symbols.place_item_sharp,
                color: Theme.of(context).colorScheme.secondary,
                size: 40,
              ),
            )
          : const SizedBox(width: 1),
    );
  }
}
