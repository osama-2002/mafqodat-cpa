import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mafqodat/screens/user_portal/report_form.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:mafqodat/screens/user_portal/claim_form.dart';
import 'package:mafqodat/widgets/user_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  DocumentSnapshot? userData;

  void _getUserData() async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      userData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = Center(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: userData != null
              ? [
                  Text(
                    'Hello ${userData!['name']}\nhow can we help you today?',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton.icon(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ClaimForm()));
                    },
                    label: const Text('I have lost an item',
                        style: TextStyle(fontSize: 20)),
                    icon: const Icon(Symbols.person_raised_hand),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportForm()));
                    },
                    label: const Text('I have found an item',
                        style: TextStyle(fontSize: 20)),
                    icon: const Icon(Symbols.approval_delegation),
                  ),
                ]
              : [const CircularProgressIndicator()]),
    );
    if (_currentIndex == 1) {
      activePage = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You don't have any notifications",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
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
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
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
            title: const Text("Home"),
            selectedColor: Theme.of(context).colorScheme.primary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            selectedColor: Theme.of(context).colorScheme.primary,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
