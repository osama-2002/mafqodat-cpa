import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:mafqodat/services/notification_services.dart' as notification_services;

var auth = FirebaseAuth.instance;
var fireStore = FirebaseFirestore.instance;

String get currentUid {
  return auth.currentUser!.uid;
}

Future<void> signIn({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    UserCredential userData =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    notification_services.checkUserToken(userData.user!.uid);
  } on FirebaseAuthException catch (e) {
    _handleAuthErrors(e, context);
  }
}

Future<void> signUp({
  required String email,
  required String password,
  required BuildContext context,
  required Map<String, dynamic> data,
}) async {
  try {
    final UserCredential userData = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    auth.currentUser!.sendEmailVerification();
    saveUserData(userData.user!.uid, data);
  } on FirebaseAuthException catch (e) {
    _handleAuthErrors(e, context);
  }
}

void saveUserData(String id, Map<String, dynamic> data) async {
  await fireStore.collection('users').doc(id).set(data);
  await notification_services.saveUserToken(id);
}

void _handleAuthErrors(FirebaseAuthException e, BuildContext context) {
  if (e.code == 'weak-password') {
    _showSnackBar(translate("WeakPass"), context);
  } else if (e.code == 'email-already-in-use') {
    _showSnackBar(translate("AccExist"), context);
  } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
    _showSnackBar(translate("WrongPass"), context);
  } else if (e.code == 'user-not-found') {
    _showSnackBar(translate("UserNotFound"), context);
  } else if (e.code == 'invalid-email') {
    _showSnackBar(translate("InvalidEmail"), context);
  } else {
    _showSnackBar(translate("DiffError"), context);
  }
}

void _showSnackBar(String message, BuildContext context) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
    ));
  }
}

Future<void> checkEmailVerification(BuildContext context) async {
  await auth.currentUser!.reload();
  if (auth.currentUser!.emailVerified) {
    await signOut();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(translate('notVerified'))),
    );
  }
}

Future<void> resendVerificationEmail(BuildContext context) async {
  try {
    await auth.currentUser!.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(translate('vEmailSent'))),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(translate('vEmailFailed'))),
    );
  }
}

Future<void> signOut() async {
  await auth.signOut();
}

Future<DocumentSnapshot<Map<String, dynamic>>> get adminData async {
  return await fireStore.collection('admins').doc(currentUid).get();
}

Future<DocumentSnapshot<Map<String, dynamic>>> get userData async {
  return await fireStore.collection('users').doc(currentUid).get();
}

Future<void> resetPassword({required String email}) async {
  await auth.sendPasswordResetEmail(email: email);
}

Future<void> updateDisplayName({
  required String name,
  required bool isUser,
}) async {
  if (isUser) {
    await fireStore.collection('users').doc(currentUid).update(
      {
        'name': name,
      },
    );
  } else {
    await fireStore.collection('admins').doc(currentUid).update(
      {
        'name': name,
      },
    );
  }
}

Future<void> updatePhoneNumber({
  required String phoneNumber,
  required bool isUser,
}) async {
  if (isUser) {
    await fireStore.collection('users').doc(currentUid).update(
      {
        'phoneNumber': phoneNumber,
      },
    );
  } else {
    await fireStore.collection('admins').doc(currentUid).update(
      {
        'phoneNumber': phoneNumber,
      },
    );
  }
}
