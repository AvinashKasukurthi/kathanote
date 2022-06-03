import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kathanote/model/person.dart';
import 'package:kathanote/view/contacts.dart';
import 'package:kathanote/view/person_detail.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utilities/home_header.dart';

class Home extends StatefulWidget {
  static const route = "/home";
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  List<Person> persons = [];

  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.of(context).pushNamed(routeName).then((value) {
        setState(() {});
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final contactStream = FirebaseFirestore.instance
        .collection("users/$userId/contacts")
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HomeHeader(),
              const TransactionHeader(
                showDate: false,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: contactStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      color: Colors.blueAccent,
                    );
                  }
                  return Column(
                    children: [
                      ...snapshot.data!.docs.map((data) {
                        var person = Person(
                          id: data.id,
                          name: data['name'],
                          initials: data['initials'],
                          phoneNumber: data['phoneNumber'],
                          youGave: data.data().toString().contains("youGave")
                              ? data["youGave"]
                              : 0.0,
                          youGot: data.data().toString().contains("youGot")
                              ? data["youGot"]
                              : 0.0,
                        );
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PersonTransaction(
                            key: Key(person.id),
                            person: person,
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _askPermissions(ContactsPage.route);
        },
        label: const Text("Add from contacts"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class TransactionHeader extends StatelessWidget {
  const TransactionHeader({
    Key? key,
    required this.showDate,
  }) : super(key: key);
  final bool showDate;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 32,
                child: Text(showDate ? "Date" : "Name"),
              ),
              const Text("You Gave"),
              const Text("You Got"),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}

class PersonTransaction extends StatefulWidget {
  const PersonTransaction({
    Key? key,
    required this.person,
  }) : super(key: key);

  final Person person;

  @override
  State<PersonTransaction> createState() => _PersonTransactionState();
}

class _PersonTransactionState extends State<PersonTransaction> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, PersonDetail.route, arguments: {
          "personId": widget.person.id,
        }).then((value) async {
          final userID = FirebaseAuth.instance.currentUser!.uid;
          final doc = await FirebaseFirestore.instance
              .collection("users/$userID/contacts")
              .doc(widget.person.id)
              .get();
          if (doc.data()!.containsKey('youGave')) {
            setState(() {
              widget.person.youGave = doc['youGave'];
            });
          }
          if (doc.data()!.containsKey('youGot')) {
            setState(() {
              widget.person.youGot = doc['youGot'];
            });
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Row(
          children: [
            Flexible(
              flex: 6,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    child: Text(widget.person.initials),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    widget.person.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red.shade400,
                    ),
                    child: Text(
                      '₹${widget.person.youGave.toInt()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.green.shade400,
                    ),
                    child: Text(
                      '₹ ${widget.person.youGot.toInt()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
