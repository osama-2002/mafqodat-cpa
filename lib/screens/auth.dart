import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _selectedGender = "Male";
  bool isLogin = true;
  bool isUser = true;
  int genderToggleSwitchIndex = 0;

  void _unfocusTextFields() {
    _focusScopeNode.unfocus();
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusTextFields,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          title: Text(
            isLogin ? 'Login Page' : 'Sign Up Page',
          ),
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
                            children: [
                              if (!isLogin)
                                TextFormField(
                                  controller: _firstNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  cursorHeight: 20,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    labelText: 'First name',
                                    labelStyle: TextStyle(
                                      color: isUser
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                    hintText: "Enter your First name",
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      gapPadding: 0.0,
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.blue, width: 1.5),
                                    ),
                                  ),
                                ),
                              if (!isLogin) const SizedBox(height: 20),
                              if (!isLogin)
                                TextFormField(
                                  controller: _lastNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  cursorHeight: 20,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    labelText: 'Last name',
                                    labelStyle: TextStyle(
                                      color: isUser
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                    hintText: "Enter your Last name",
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      gapPadding: 0.0,
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide(
                                          color: Colors.blue, width: 1.5),
                                    ),
                                  ),
                                ),
                              if (!isLogin) const SizedBox(height: 20),
                              if (!isLogin)
                                ToggleSwitch(
                                  minWidth: 90.0,
                                  initialLabelIndex: genderToggleSwitchIndex,
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
                                    [Theme.of(context).colorScheme.primary],
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
                              if (!isLogin) const SizedBox(height: 30),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Invalid Email Format';
                                  }
                                  return null;
                                },
                                cursorHeight: 20,
                                autofocus: false,
                                decoration: InputDecoration(
                                  labelText: 'Email ',
                                  labelStyle: TextStyle(
                                    color: isUser
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                  hintText: "example@domain.com",
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: isUser
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    gapPadding: 0.0,
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                        color: isUser
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  if (value.length < 5) {
                                    return 'Password must contain 5 characters at least';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                cursorHeight: 20,
                                autofocus: false,
                                decoration: InputDecoration(
                                  labelText: 'Password ',
                                  labelStyle: TextStyle(
                                    color: isUser
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                  hintText: "Password",
                                  prefixIcon: Icon(
                                    Icons.pin,
                                    color: isUser
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    gapPadding: 0.0,
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                        color: isUser
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isUser
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () {
                                  submitInput();
                                },
                                child: Text(
                                  isLogin ? 'Login' : 'signUp',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isUser) const SizedBox(height: 15),
                              if (isUser)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isLogin)
                    ToggleSwitch(
                      minWidth: 90.0,
                      cornerRadius: 20.0,
                      activeBgColors: [
                        [Theme.of(context).colorScheme.primary],
                        [Theme.of(context).colorScheme.secondary]
                      ],
                      activeFgColor: Theme.of(context).colorScheme.onSurface,
                      inactiveBgColor: const Color.fromARGB(255, 200, 200, 200),
                      inactiveFgColor: Theme.of(context).colorScheme.onSurface,
                      initialLabelIndex: isUser ? 0 : 1,
                      totalSwitches: 2,
                      labels: const ['User', 'Admin'],
                      radiusStyle: true,
                      onToggle: (index) {
                        setState(() {
                          isUser = !isUser;
                        });
                      },
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
      'email': _emailController.text,
      'isUser': true,
      'name': '${_firstNameController.text} ${_lastNameController.text}',
      'gender' : _selectedGender
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
