import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:mafqodat/screens/auth.dart';
import 'package:mafqodat/screens/user_portal/home.dart' as user_portal;
import 'package:mafqodat/screens/admin_portal/home.dart' as admin_portal;
import 'package:mafqodat/theme.dart' as custom_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'ar',
    supportedLocales: ['ar', 'en'],
  );
  runApp(
    LocalizedApp(delegate, const ProviderScope(child: MyApp())),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool?> _getUserType(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return userDoc['isUser'] as bool?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    bool? isUser;

    final LocalizationDelegate localizationDelegate =
        LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'Mafqodat',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        theme: custom_theme.theme,
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String uid = snapshot.data!.uid;
              print(uid);
              return FutureBuilder<bool?>(
                future: _getUserType(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(color: Colors.white ,child: const Center(child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    return Container(color: Colors.white ,child: const Center(child: Text('Error loading user data', style: TextStyle(color: Colors.black),)));
                  } else if (snapshot.hasData) {
                    isUser = snapshot.data;
                    return isUser == true
                        ? const user_portal.Home()
                        : const admin_portal.Home();
                  } else {
                    return Container(color: Colors.white, child: const Center(child: Text('User data not found', style: TextStyle(color: Colors.black))));
                  }
                },
              );
            }
            return const AuthenticationPage();
          },
        ),
      ),
    );
  }
}
