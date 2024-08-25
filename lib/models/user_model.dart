
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? name;String? email;
  String? password;
  String?phone;
  int? status;
  DateTime? createdAt;

  UserModel(
      {this.uid,
        this.name,
        this.email,
        this.password,
        this.createdAt,
        this.status,
        this.phone,
       });



  // fromJson
// Convert DocumentSnapshot to UserModel object
  factory UserModel.fromJoson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name']?? '',

      password: data['password']??'',
      email:data['email']?? '',
      phone: data['phone']??'',
      status: data['status']?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate() ?? DateTime.now(),
    );
  }

  // Convert UserModel object to Map
  Map<String, dynamic> toMap() {
    return {
      'uid':uid,
      'name': name,
      'email': email,
      'password': password,
      'status': status,
      'phone':phone,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }




// toMap



}
