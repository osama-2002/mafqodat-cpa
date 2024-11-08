import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mafqodat/services/auth_services.dart' as auth_services;
import 'package:mafqodat/screens/forgotten_password.dart';
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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalNumberController = TextEditingController();
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
            isLogin ? translate("LogPage") : translate("SignPage"),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                String newLanguage = LocalizedApp.of(context)
                            .delegate
                            .currentLocale
                            .toString() ==
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
                                        labelText: "${translate("Email")} ",
                                        hintText: 'example@domain.com',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          if (!value.contains('@')) {
                                            return translate("InvalidEmail");
                                          }
                                          return null;
                                        },
                                        prefixIcon: Icons.email,
                                      ),
                                      const SizedBox(height: 30),
                                      CustomTextFormField(
                                        controller: _passwordController,
                                        labelText: "${translate("Password")} ",
                                        hintText: '',
                                        prefixIcon: Icons.lock,
                                        isUser: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          if (value.length < 5) {
                                            return translate("InvalidPass");
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
                                          translate("ForgottenPassword"),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        onPressed: () {
                                          submitInput();
                                        },
                                        child: Text(
                                          isLogin
                                              ? translate("Login")
                                              : translate("Sign"),
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
                                                ? translate("NoAcc")
                                                : translate("Acc"),
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
                                              isLogin
                                                  ? translate("Sign")
                                                  : translate("Login"),
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
                                        labelText: "${translate("Name")} ",
                                        hintText: translate("DisplayName"),
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          return null;
                                        },
                                        prefixIcon: Symbols.text_format,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _nationalNumberController,
                                        labelText:
                                            "${translate("NationalNo")} ",
                                        hintText: translate("NationalHint"),
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(value)) {
                                            return translate("InvalidNational");
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
                                        cornerRadius: 17,
                                        textDirectionRTL:
                                            LocalizedApp.of(context)
                                                    .delegate
                                                    .currentLocale
                                                    .toString() ==
                                                'ar',
                                        activeFgColor: Colors.white,
                                        inactiveBgColor: Colors.grey,
                                        inactiveFgColor: Colors.white,
                                        totalSwitches: 2,
                                        labels: [
                                          translate('male'),
                                          translate('female')
                                        ],
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
                                        labelText: "${translate("Email")} ",
                                        hintText: 'example@domain.com',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          if (!value.contains('@')) {
                                            return translate("InvalidEmail");
                                          }
                                          return null;
                                        },
                                        prefixIcon: Icons.email,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _phoneNumberController,
                                        labelText: "${translate("PhoneNo")} ",
                                        hintText: '7xxxxxxxx',
                                        isUser: true,
                                        isPassword: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(value)) {
                                            return translate("InvalidPhone");
                                          }
                                          return null;
                                        },
                                        prefixIcon: Icons.phone_sharp,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _passwordController,
                                        labelText: "${translate("Password")} ",
                                        hintText: translate("PassHint"),
                                        prefixIcon: Icons.lock,
                                        isUser: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          if (value.length < 5) {
                                            return translate("InvalidPass");
                                          }
                                          return null;
                                        },
                                        isPassword: true,
                                      ),
                                      const SizedBox(height: 26),
                                      CustomTextFormField(
                                        controller: _confirmPasswordController,
                                        labelText: translate("ConfirmPass"),
                                        hintText: translate("ReEnterPass"),
                                        prefixIcon: Icons.lock,
                                        isUser: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return translate("NotEmpty");
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return translate("WrongPass");
                                          }
                                          return null;
                                        },
                                        isPassword: true,
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        onPressed: () {
                                          submitInput();
                                        },
                                        child: Text(
                                          isLogin
                                              ? translate("Login")
                                              : translate("Sign"),
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
                                                ? translate("NoAcc")
                                                : translate("Acc"),
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
                                              isLogin
                                                  ? translate("Sign")
                                                  : translate("Login"),
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
    if (_formKey.currentState!.validate()) {
      if (isLogin) {
        await auth_services.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          context: context,
        );
      } else {
        await auth_services.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          context: context,
          data: {
            'name': _nameController.text.trim(),
            'gender': _selectedGender,
            'email': _emailController.text.trim(),
            'nationalNumber': _nationalNumberController.text,
            'phoneNumber': _phoneNumberController.text,
          },
        );
      }
    }
  }
}
