import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Future<void> checkEmailVerification() async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      await FirebaseAuth.instance.signOut();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('notVerified'))),
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('vEmailSent'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('vEmailFailed'))),
      );
    }
  }

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
            onPressed: () {
              if (LocalizedApp.of(context).delegate.currentLocale.toString() ==
                  'en') {
                changeLocale(context, 'ar');
              } else {
                changeLocale(context, 'en');
              }
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
              onPressed: () {
                resendVerificationEmail();
              },
              child: Text(translate('resendVerification')),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                checkEmailVerification();
              },
              child: Text(translate('verificationDone')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Text(translate('backToLogin')),
            ),
          ],
        ),
      ),
    );
  }
}
