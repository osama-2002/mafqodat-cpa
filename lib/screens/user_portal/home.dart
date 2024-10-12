import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:mafqodat/services/auth_services.dart' as auth_services;
import 'package:mafqodat/services/notification_services.dart' as notification_services;
import 'package:mafqodat/screens/user_portal/guide.dart';
import 'package:mafqodat/screens/user_portal/report_form.dart';
import 'package:mafqodat/screens/user_portal/claim_form.dart';
import 'package:mafqodat/widgets/user_portal_widgets/notifications_list.dart';
import 'package:mafqodat/widgets/user_portal_widgets/user_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  DocumentSnapshot<Map<String, dynamic>>? userData;

  void _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> data = await auth_services.userData;
    setState(() {
      userData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    notification_services.checkNotificationPermission(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = Center(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: userData != null
              ? [
                  Text(
                    '${translate("hello")} ${userData!['name']}\n${translate("help")}',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ClaimForm()));
                    },
                    label: Text(translate("LostButton"),
                        style: const TextStyle(fontSize: 20)),
                    icon: const Icon(Symbols.person_raised_hand),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ReportForm()));
                    },
                    label: Text(translate("FoundButton"),
                        style: const TextStyle(fontSize: 20)),
                    icon: const Icon(Symbols.approval_delegation),
                  ),
                ]
              : [const CircularProgressIndicator()]),
    );
    if (_currentIndex == 1) {
      activePage = const SingleChildScrollView(
        child: NotificationsList(),
      );
    }
    if (_currentIndex == 2) {
      activePage = UserProfile(userData: userData!);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("appName")),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await auth_services.signOut();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          translate('Confirm'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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
                color: Theme.of(context).colorScheme.primary,
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
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(translate("GUide")),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GuidePage()));
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
            title: Text(translate("Home")),
            selectedColor: Theme.of(context).colorScheme.primary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.notifications),
            title: Text(translate("Notifications")),
            selectedColor: Theme.of(context).colorScheme.primary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: Text(translate("Profile")),
            selectedColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
