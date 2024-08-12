import 'package:uuid/uuid.dart';

Uuid uuid = const Uuid();

class User {
  final String id;
  //final String name;
  final String email;
  final String password;
  //final String gender;
  //final String nationalNumber;

  User({
    String? id,
    //required this.name,
    required this.email,
    required this.password,
    //required this.gender,
    //required this.nationalNumber,
  }) : id = id ?? uuid.v4();
}
