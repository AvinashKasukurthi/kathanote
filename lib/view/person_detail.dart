import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kathanote/model/person_transaction.dart';

import 'package:kathanote/utilities/total_debits_and_credits.dart';
import 'package:kathanote/view/home.dart';

class PersonDetail extends StatefulWidget {
  const PersonDetail({Key? key}) : super(key: key);

  static const route = "/person_detail";

  @override
  State<PersonDetail> createState() => _PersonDetailState();
}

class _PersonDetailState extends State<PersonDetail> {
  final TextEditingController _youGaveController = TextEditingController();
  final TextEditingController _youGotController = TextEditingController();

  double totalGave = 0;
  double totalGot = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference personDoc =
        FirebaseFirestore.instance.collection('users/${user!.uid}/contacts');
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    String id = args['personId']!;
    Stream<QuerySnapshot<Map<String, dynamic>>> transactionStream =
        FirebaseFirestore.instance
            .collection('users/${user.uid}/transactions')
            .where('contactId', isEqualTo: id)
            .orderBy('createdAt')
            .snapshots();

    personDoc.doc(id).set({
      "createdAt": Timestamp.now(),
    }, SetOptions(merge: true));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: FutureBuilder(
                future: personDoc.doc(id).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }

                  if (snapshot.hasData && !snapshot.data!.exists) {
                    return const Text("Document does not exist");
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        Container(
                          color: Colors.blueAccent,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40.0,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    data['initials'],
                                    style: const TextStyle(
                                      fontSize: 28.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      data['name'],
                                      style: const TextStyle(
                                        fontSize: 26,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  data['phoneNumber']
                                          .toString()
                                          .startsWith('+91')
                                      ? data["phoneNumber"]
                                      : "+91${data['phoneNumber']}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                ),
                                const TotalDebitsAndCredits(),
                              ],
                            ),
                          ),
                        ),
                        const TransactionHeader(
                          showDate: true,
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: transactionStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text("Something went wrong!");
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                color: Colors.blueAccent,
                              );
                            }
                            return Column(
                              children: [
                                ...snapshot.data!.docs.map((doc) {
                                  PersonTransactionModal transaction;
                                  print(doc.data());
                                  if (doc
                                      .data()
                                      .toString()
                                      .contains('youGot')) {
                                    transaction = PersonTransactionModal(
                                      id: doc.id,
                                      contactId: doc['contactId'],
                                      time: doc['createdAt'],
                                      balance: doc['balanceAtPoint'],
                                      youGot: doc['youGot'],
                                    );
                                    // print(data['youGot']);
                                  } else {
                                    transaction = PersonTransactionModal(
                                      id: doc.id,
                                      contactId: doc['contactId'],
                                      time: doc['createdAt'],
                                      balance: doc['balanceAtPoint'],
                                      youGave: doc['youGave'],
                                    );
                                    // print(data['youGave']);
                                  }
                                  print(transaction.youGave);
                                  return PersonTransaction(
                                    transaction: transaction,
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return const Center(
                    child: LinearProgressIndicator(color: Colors.blueAccent),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red.shade500),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("You Gave"),
                              content: TextField(
                                autofocus: true,
                                decoration: const InputDecoration(),
                                controller: _youGaveController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text("submit"),
                                  onPressed: () async {
                                    await yougave(id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          "You Gave",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green.shade500),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("You Got"),
                              content: TextField(
                                autofocus: true,
                                decoration: const InputDecoration(),
                                controller: _youGotController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text("submit"),
                                  onPressed: () async {
                                    await youGot(id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          "You Got",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> yougave(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    final headDocument =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final headDoc = await headDocument.get();
    final document = FirebaseFirestore.instance
        .collection('users/${user.uid}/contacts')
        .doc(id);
    final doc = await document.get();

    final contactCollection =
        FirebaseFirestore.instance.collection('users/${user.uid}/contacts');
    final totalBalDoc = await contactCollection.doc(id).get();

    double prevTotalBal = 0;

    bool isYouGave = totalBalDoc.data()!.containsKey('youGave');
    bool isYouGot = totalBalDoc.data()!.containsKey('youGot');

    if (isYouGot && isYouGave) {
      prevTotalBal = totalBalDoc['youGot'] - totalBalDoc['youGave'];
    } else if (isYouGot) {
      prevTotalBal = totalBalDoc['youGot'];
    } else if (isYouGave) {
      prevTotalBal = 0.0 - totalBalDoc['youGave'];
    } else {
      prevTotalBal = 0;
    }

    if (doc.data()!.containsKey('youGave')) {
      totalGave = doc['youGave'] + double.parse(_youGaveController.text.trim());
      document.set({
        "youGave": totalGave,
      }, SetOptions(merge: true));
    } else {
      totalGave = double.parse(_youGaveController.text.trim());
      document.set({
        "youGave": totalGave,
      }, SetOptions(merge: true));
    }
    print(headDoc.data());
    if (headDoc.data() != null && headDoc.data()!.containsKey('youGave')) {
      final headDocGave = headDoc['youGave'];
      headDocument.set({
        "youGave": headDocGave + double.parse(_youGaveController.text.trim()),
      }, SetOptions(merge: true));
    } else {
      headDocument.set({
        "youGave": double.parse(_youGaveController.text.trim()),
      }, SetOptions(merge: true));
    }

    final transactionCollection =
        FirebaseFirestore.instance.collection('users/${user.uid}/transactions');

    print(prevTotalBal);
    transactionCollection.add({
      "contactId": id,
      "createdAt": Timestamp.now(),
      "youGave": double.parse(_youGaveController.text.trim()),
      "balanceAtPoint":
          prevTotalBal - double.parse(_youGaveController.text.trim()),
    });
    _youGaveController.text = "";
  }

  Future<void> youGot(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    final headDocument = FirebaseFirestore.instance.doc('users/${user!.uid}');
    final headDoc = await headDocument.get();
    final document = FirebaseFirestore.instance
        .collection('users/${user.uid}/contacts')
        .doc(id);
    final doc = await document.get();

    double prevTotalBal;
    final contactCollection =
        FirebaseFirestore.instance.collection('users/${user.uid}/contacts');
    final totalBalDoc = await contactCollection.doc(id).get();

    bool isYouGave = totalBalDoc.data()!.containsKey('youGave');
    bool isYouGot = totalBalDoc.data()!.containsKey('youGot');
    if (isYouGot && isYouGave) {
      prevTotalBal = totalBalDoc['youGot'] - totalBalDoc['youGave'];
    } else if (isYouGot) {
      prevTotalBal = totalBalDoc['youGot'];
    } else if (isYouGave) {
      prevTotalBal = 0.0 - totalBalDoc['youGave'];
    } else {
      prevTotalBal = 0;
    }

    if (doc.data()!.containsKey('youGot')) {
      totalGot = doc['youGot'] + double.parse(_youGotController.text.trim());
      document.set({
        "youGot": totalGot,
      }, SetOptions(merge: true));
    } else {
      totalGot = double.parse(_youGotController.text.trim());
      document.set({
        "youGot": totalGot,
      }, SetOptions(merge: true));
    }

    if (headDoc.data()!.containsKey('youGot')) {
      final headDocGave = headDoc['youGot'];
      headDocument.set({
        "youGot": headDocGave + double.parse(_youGotController.text.trim()),
      }, SetOptions(merge: true));
    } else {
      headDocument.set({
        "youGot": double.parse(_youGotController.text.trim()),
      }, SetOptions(merge: true));
    }

    final transactionCollection =
        FirebaseFirestore.instance.collection('users/${user.uid}/transactions');

    transactionCollection.add({
      "contactId": id,
      "createdAt": Timestamp.now(),
      "youGot": double.parse(_youGotController.text.trim()),
      "balanceAtPoint":
          prevTotalBal + double.parse(_youGotController.text.trim()),
    });
    _youGotController.text = "";
  }
}

class PersonTransaction extends StatelessWidget {
  const PersonTransaction({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final PersonTransactionModal transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMEd().format(transaction.time.toDate()),
                ),
                Container(
                  margin: const EdgeInsets.all(3.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      color: transaction.balance >= 0
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                      borderRadius: BorderRadius.circular(
                        3.0,
                      )),
                  child: Text("₹ ${transaction.balance}"),
                )
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: transaction.youGave != null
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (transaction.youGave != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red.shade400,
                    ),
                    child: Text(
                      '₹ ${transaction.youGave}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                if (transaction.youGot != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.green.shade400,
                    ),
                    child: Text(
                      '₹ ${transaction.youGot}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
