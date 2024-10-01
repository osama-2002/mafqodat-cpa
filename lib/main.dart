import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:mafqodat/screens/auth.dart';
import 'package:mafqodat/screens/user_portal/email_verification.dart';
import 'package:mafqodat/services/auth_services.dart' as auth_services;
import 'package:mafqodat/screens/user_portal/home.dart' as user_portal;
import 'package:mafqodat/screens/admin_portal/home.dart' as admin_portal;
import 'package:mafqodat/theme.dart' as custom_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
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
    DocumentSnapshot adminDoc =
        await FirebaseFirestore.instance.collection('admins').doc(uid).get();

    if (userDoc.exists) {
      return true;
    }
    if (adminDoc.exists) {
      return false;
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
        title: translate("appName"),
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
          stream: auth_services.auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String uid = snapshot.data!.uid;
              return FutureBuilder<bool?>(
                future: _getUserType(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.white,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      color: Colors.white,
                      child: const Center(
                          child: Text(
                        'Error loading user data',
                        style: TextStyle(color: Colors.black),
                      )),
                    );
                  } else if (snapshot.hasData) {
                    isUser = snapshot.data;
                    if (isUser == true) {
                      if (auth_services.auth.currentUser!.emailVerified) {
                        return const user_portal.Home();
                      } else {
                        return const EmailVerificationScreen();
                      }
                    }
                    if (isUser == false) return const admin_portal.Home();
                  }
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text('User data not found',
                          style: TextStyle(color: Colors.black)),
                    ),
                  );
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
