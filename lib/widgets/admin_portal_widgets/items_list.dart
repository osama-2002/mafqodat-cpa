import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:mafqodat/widgets/custom_dropdown_button.dart';
import 'package:mafqodat/widgets/admin_portal_widgets/item.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({super.key});

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  String? filter;
  final TextEditingController _searchController = TextEditingController();

  void _onDropdownValueChanged(String? value) {
    setState(() {
      filter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: filter == null
          ? FirebaseFirestore.instance
              .collection('items')
              .where('adminId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('items')
              .where('adminId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('type', isEqualTo: filter)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black54),
          ));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomDropdownButton(
                    isUser: false,
                    isFilter: true,
                    controller: _searchController,
                    selectedDropDownValue: filter,
                    onChanged: _onDropdownValueChanged,
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        filter = null;
                      });
                    },
                    child: Text(
                      translate("ResetFilter"),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 280),
              Center(
                child: Text(
                  translate("NoItems"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomDropdownButton(
                    isUser: false,
                    isFilter: true,
                    controller: _searchController,
                    selectedDropDownValue: filter,
                    onChanged: _onDropdownValueChanged),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      filter = null;
                    });
                  },
                  child: Text(
                    translate("ResetFilter"),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                QueryDocumentSnapshot item = snapshot.data!.docs[index];
                String itemId = item.id;
                Map<String, dynamic> itemData =
                    item.data() as Map<String, dynamic>;
                return Item(
                  data: itemData,
                  id: itemId,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
