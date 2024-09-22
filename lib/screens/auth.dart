import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mafqodat/screens/forgotten_password.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:mafqodat/widgets/custom_text_field.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalNumberController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _selectedGender = "Male";
  int genderToggleSwitchIndex = 0;
  bool isLogin = true;

  void _unfocusTextFields() {
    _focusScopeNode.unfocus();
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusTextFields,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            isLogin ? 'Login Page' : 'Sign Up Page',
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (LocalizedApp.of(context)
                        .delegate
                        .currentLocale
                        .toString() ==
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
        body: FocusScope(
          node: _focusScopeNode,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 30, bottom: 20, left: 20, right: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32.0),
                      child: Image.asset(
                        'assets/images/logo-removebg.png',
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    borderOnForeground: false,
                    elevation: 30,
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: isLogin
                                  ? [
                                      CustomTextFormField(
                                        controller: _emailController,
                                        labelText: 'Email ',
                                        hintText: 'example@domain.com',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Invalid Email Format';
                                          }
                                          return null;
                                        },
                                        prefixIcon: Icons.email,
                                      ),
                                      const SizedBox(height: 30),
                                      CustomTextFormField(
                                        controller: _passwordController,
                                        labelText: 'Password ',
                                        hintText: '',
                                        prefixIcon: Icons.lock,
                                        isUser: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          if (value.length < 5) {
                                            return 'Password must contain 5 characters at least';
                                          }
                                          return null;
                                        },
                                        isPassword: true,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return const ForgottenPassword(
                                                  isUser: true,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Forgotten Password?",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).colorScheme.primary),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          submitInput();
                                        },
                                        child: Text(
                                          isLogin ? 'Login' : 'signUp',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                       const SizedBox(height: 15),
                                      
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              isLogin
                                                  ? "don't have an account?"
                                                  : "already has an account?",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isLogin = !isLogin;
                                                });
                                              },
                                              child: Text(
                                                isLogin ? "signUp" : "login",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    ]
                                  : [
                                      CustomTextFormField(
                                        controller: _nameController,
                                        labelText: 'Name ',
                                        hintText: 'Choose you display name',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          return null;
                                        },
                                        prefixIcon: Symbols.text_format,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _nationalNumberController,
                                        labelText: 'National Number ',
                                        hintText:
                                            'National number in your Id card',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(value)) {
                                            return 'National number consists of numbers only';
                                          }
                                          return null;
                                        },
                                        prefixIcon: Symbols.id_card,
                                      ),
                                      const SizedBox(height: 26),
                                      ToggleSwitch(
                                        minWidth: 90.0,
                                        initialLabelIndex:
                                            genderToggleSwitchIndex,
                                        cornerRadius: 20.0,
                                        activeFgColor: Colors.white,
                                        inactiveBgColor: Colors.grey,
                                        inactiveFgColor: Colors.white,
                                        totalSwitches: 2,
                                        labels: const ['Male', 'Female'],
                                        icons: const [
                                          FontAwesomeIcons.mars,
                                          FontAwesomeIcons.venus
                                        ],
                                        activeBgColors: [
                                          [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                          ],
                                          const [Colors.pink]
                                        ],
                                        onToggle: (index) {
                                          setState(() {
                                            if (index == 0) {
                                              _selectedGender = 'Male';
                                              genderToggleSwitchIndex = 0;
                                            } else {
                                              _selectedGender = 'Female';
                                              genderToggleSwitchIndex = 1;
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _emailController,
                                        labelText: 'Email ',
                                        hintText: 'example@domain.com',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Invalid Email Format';
                                          }
                                          return null;
                                        },
                                        prefixIcon: Icons.email,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _phoneNumberController,
                                        labelText: 'Phone number ',
                                        hintText: '7xxxxxxxx',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(value)) {
                                            return 'Invalid phone number';
                                          }
                                          return null;
                                        },
                                        prefixIcon: Icons.phone_sharp,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _passwordController,
                                        labelText: 'Password ',
                                        hintText: 'Create a strong password',
                                        prefixIcon: Icons.lock,
                                        isUser: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          if (value.length < 5) {
                                            return 'Password must contain 5 characters at least';
                                          }
                                          return null;
                                        },
                                        isPassword: true,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _confirmPasswordController,
                                        labelText: 'Confirm password ',
                                        hintText: 'Enter your password again',
                                        prefixIcon: Icons.lock,
                                        isUser: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field can not be empty';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Wrong Password';
                                          }
                                          return null;
                                        },
                                        isPassword: true,
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          submitInput();
                                        },
                                        child: Text(
                                          isLogin ? 'Login' : 'signUp',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                       const SizedBox(height: 12),
                                      
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              isLogin
                                                  ? "don't have an account?"
                                                  : "already has an account?",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isLogin = !isLogin;
                                                });
                                              },
                                              child: Text(
                                                isLogin ? "signUp" : "login",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submitInput() async {
    try {
      if (_formKey.currentState!.validate()) {
        if (isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
        } else {
          final userData =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          saveUserData(userData.user!.uid);
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthErrors(e);
    }
  }

  void saveUserData(String id) {
    FirebaseFirestore.instance.collection('users').doc(id).set({
      'name': _nameController.text,
      'gender': _selectedGender,
      'email': _emailController.text,
      'nationalNumber': _nationalNumberController.text,
      'phoneNumber': _phoneNumberController.text,
    });
  }

  void _handleAuthErrors(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      _showSnackBar("The password provided is too weak.");
    } else if (e.code == 'email-already-in-use') {
      _showSnackBar("The account already exists for that email.");
    } else {
      _showSnackBar("An error occurred while creating the account.");
    }
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ));
    }
  }
}
