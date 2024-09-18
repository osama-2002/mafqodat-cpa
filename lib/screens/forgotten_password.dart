import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mafqodat/widgets/custom_text_field.dart';

class ForgottenPassword extends StatefulWidget {
  const ForgottenPassword({super.key, required this.isUser});
  final bool isUser;

  @override
  State<ForgottenPassword> createState() => _ForgottenPasswordState();
}

class _ForgottenPasswordState extends State<ForgottenPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;

  Future<void> _sendResetEmail(String email) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email Sent")),
      );
      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgotten Password'),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(6),
          child: _emailSent
              ? Center(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/email_icon.png'),
                    const SizedBox(height: 28),
                    const Text(
                      'An email has been sent to your\nemail address.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ))
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enter your email address below to reset your password.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        isUser: widget.isUser,
                        prefixIcon: Icons.email,
                        isPassword: false,
                        controller: _emailController,
                        labelText: "Email ",
                        hintText: "example@domain.com",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _sendResetEmail(_emailController.text);
                          }
                        },
                        child: Text(
                          'Send Email',
                          style: TextStyle(
                            color: widget.isUser
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
