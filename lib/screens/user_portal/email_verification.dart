import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mafqodat/services/auth_services.dart' as auth_services;
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          translate('verificationTitle'),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              String newLanguage =
                  LocalizedApp.of(context).delegate.currentLocale.toString() ==
                          'en'
                      ? 'ar'
                      : 'en';

              changeLocale(context, newLanguage);
              await prefs.setString(
                'selectedLanguage',
                newLanguage,
              );
            },
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              translate('verificationHeadline'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              translate('verificationMessage'),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await auth_services.resendVerificationEmail(context);
              },
              child: Text(translate('resendVerification')),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await auth_services.checkEmailVerification(context);
              },
              child: Text(translate('verificationDone')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await auth_services.signOut();
              },
              child: Text(translate('backToLogin')),
            ),
          ],
        ),
      ),
    );
  }
}
