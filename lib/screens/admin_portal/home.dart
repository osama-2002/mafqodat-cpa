import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget activePage = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translate("bismillah"),
            style: const TextStyle(fontSize: 24,),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (_currentIndex == 1) {
      activePage = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Claims",
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      );
    }
    if (_currentIndex == 2) {
      activePage = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Possible Matches",
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      );
    }
    if (_currentIndex == 3) {
      activePage = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Profile",
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
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
