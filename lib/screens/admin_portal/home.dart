import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:mafqodat/screens/admin_portal/add_item.dart';
import 'package:mafqodat/widgets/admin_portal_widgets/matches_list.dart';
import 'package:mafqodat/widgets/admin_portal_widgets/items_list.dart';
import 'package:mafqodat/widgets/admin_portal_widgets/claims_and_reports.dart';
import 'package:mafqodat/widgets/admin_portal_widgets/admin_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  DocumentSnapshot<Map<String, dynamic>>? adminData;

  void getAdminData() async {
    DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
        .instance
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
    getAdminData();
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const SingleChildScrollView(
      child: ItemsList(),
    );
    if (_currentIndex == 1) {
      activePage = ClaimsAndReports(
        adminData: adminData!,
      );
    }
    if (_currentIndex == 2) {
      activePage = Matches(
        adminData: adminData!,
      );
    }
    if (_currentIndex == 3) {
      activePage = AdminProfile(
        adminData: adminData!,
      );
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
                    content: Text(
                      translate("SignOut?"),
                      style: const TextStyle(
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
                          translate("Cancel"),
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
                          translate("Confirm"),
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                translate("Menu"),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(translate("changeLanguage")),
              onTap: () {
                if (LocalizedApp.of(context)
                        .delegate
                        .currentLocale
                        .toString() ==
                    'en') {
                  changeLocale(context, 'ar');
                } else {
                  changeLocale(context, 'en');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.search),
            title: Text(translate("Items")),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Symbols.person_alert),
            title: Text(translate("Claims")),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.library_add_check_outlined),
            title: Text(translate("Matches")),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: Text(translate("Profile")),
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddItem(
                    adminData: adminData!,
                  );
                }));
              },
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
