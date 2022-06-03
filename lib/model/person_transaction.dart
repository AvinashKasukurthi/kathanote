import 'package:cloud_firestore/cloud_firestore.dart';

class PersonTransactionModal {
  String id;
  Timestamp time;
  double balance;
  double? youGave;
  double? youGot;
  String contactId;

  PersonTransactionModal({
    required this.id,
    required this.contactId,
    required this.time,
    required this.balance,
    this.youGave,
    this.youGot,
  });
}
