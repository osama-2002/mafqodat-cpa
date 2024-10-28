import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mafqodat/services/ai_services.dart' as ai_services;

FirebaseFirestore firestore = FirebaseFirestore.instance;

final List<String> types = [
  'Card (Bank, ID, etc.)',
  'Wallet',
  'Mobile Phone',
  'Official Document',
  'Key',
  'Laptop',
  'Bag/Backpack',
  'Watch',
  'Earphones',
  'Headphones',
  'Bracelet',
  'Necklace',
  'Clothing',
  'Camera',
  'Chargers/Adapters',
  'Glasses/Sunglasses',
  'Miscellaneous',
];

Future<void> runMatchingEngine(DocumentSnapshot<Map<String, dynamic>> adminData) async {
  for (String type in types) {
    QuerySnapshot claims = await firestore
        .collection('claims')
        .where('region', isEqualTo: adminData['region'])
        .where('type', isEqualTo: type)
        .get();
    QuerySnapshot items = await firestore
        .collection('items')
        .where('type', isEqualTo: type)
        .get();
    for (QueryDocumentSnapshot claim in claims.docs) {
      List matchedWith = claim['matchedWith'];
      for (QueryDocumentSnapshot item in items.docs) {
        if (!matchedWith.contains(item.id)) {
          if (item['color'] == claim['color']) {
            String matchDescriptionsResult =
                await ai_services.areMatchedDescriptions(
              "${claim['description']} , ${claim['imagesDescriptions']}",
              "${item['description']} , ${item['imageDescription']}",
            );
            if ((matchDescriptionsResult.trim() == 'Match')) {
              await firestore.collection('matches').add({
                'claimId': claim.id,
                'itemId': item.id,
                'isRejected': false,
                'type': type
              });
              matchedWith.add(item.id);
            }
          }
        }
      }
      firestore
          .collection('claims')
          .doc(claim.id)
          .update({'matchedWith': matchedWith});
    }
  }
}
