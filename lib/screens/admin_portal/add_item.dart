import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:mafqodat/services/user_interaction_services.dart' as ui_services;
import 'package:mafqodat/services/entity_management_services.dart' as entity_services;
import 'package:mafqodat/widgets/custom_dropdown_button.dart';
import 'package:mafqodat/widgets/custom_text_field.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key, required this.adminData});
  final DocumentSnapshot adminData;

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  String? _selectedDropDownValue;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Color? _selectedColor;
  File? _selectedImage;
  String imageUrl = "";
  Uuid uuid = const Uuid();
  bool _isLoading = false;

  void _unfocusTextFields() {
    _focusScopeNode.unfocus();
  }

  void _onDropdownValueChanged(String? newValue) {
    setState(() {
      _selectedDropDownValue = newValue;
    });
  }

  void _clearForm() {
    setState(() {
      _formKey.currentState!.reset();
      _selectedDropDownValue = null;
      _descriptionController.clear();
      _selectedImage = null;
      _selectedColor = null;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedDropDownValue != null &&
        _selectedColor != null &&
        _selectedImage != null) {
      setState(() {
        _isLoading = true;
      });
      await entity_services.addItem(
        _selectedDropDownValue!,
        _descriptionController.text,
        _selectedImage!,
        _selectedColor!.value,
        widget.adminData['location'],
        _clearForm,
        context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate("PleaseFill")),
        ),
      );
    }
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _unfocusTextFields,
        child: Scaffold(
          appBar: AppBar(
            title: Text(translate("AddItem")),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          body: FocusScope(
            node: _focusScopeNode,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomDropdownButton(
                          controller: _searchController,
                          selectedDropDownValue: _selectedDropDownValue,
                          isUser: false,
                          onChanged: _onDropdownValueChanged,
                        ),
                        const SizedBox(height: 16),
                        CustomTextFormField(
                          controller: _descriptionController,
                          labelText: translate("Description"),
                          hintText: translate("DescriptionHint"),
                          prefixIcon: Icons.description_outlined,
                          isUser: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return translate("DescriptionHint");
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            _selectedColor =
                                await ui_services.pickColor(context);
                            if (_selectedColor != null) {
                              setState(() {});
                            }
                          },
                          child: _selectedColor == null
                              ? Text(
                                  translate("PickCol"),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                )
                              : Icon(
                                  Symbols.colors,
                                  color: _selectedColor,
                                  size: 34,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: SizedBox(
                            height: 200,
                            child: Center(
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 300,
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () async {
                                        _selectedImage =
                                            await ui_services.takePicture();
                                        if (_selectedImage != null) {
                                          setState(() {});
                                        }
                                      },
                                      icon: Icon(Icons.camera,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      label: Text(
                                        translate("TakePic"),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _submit();
                              },
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    )
                                  : Text(
                                      translate("Add"),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                            ),
                            const SizedBox(width: 32),
                            ElevatedButton(
                              onPressed: _clearForm,
                              child: Text(
                                translate("Clear"),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
