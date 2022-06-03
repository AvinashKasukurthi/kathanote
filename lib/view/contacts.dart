import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:kathanote/view/person_detail.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  static const route = "/contacts";

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

  void getAllContacts() async {
    List<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);

    _contacts = contacts;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Container(
                child: const Center(
                  child: Text("Loading.."),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 24.0,
                      ),
                      const Text(
                        "Pick from your contacts",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          Contact contact = _contacts[index];

                          if (contact.displayName != null &&
                              contact.phones != null &&
                              contact.phones!.isNotEmpty) {
                            return ListTile(
                              onTap: () async {
                                final user = FirebaseAuth.instance.currentUser;

                                await FirebaseFirestore.instance
                                    .collection("users/${user!.uid}/contacts")
                                    .doc(contact.phones!.elementAt(0).value)
                                    .set({
                                  "createdAt": Timestamp.now(),
                                  "name": contact.displayName,
                                  "phoneNumber":
                                      contact.phones!.elementAt(0).value,
                                  "initials": contact.initials(),
                                }, SetOptions(merge: true)).then((value) {
                                  Navigator.pushNamed(
                                      context, PersonDetail.route,
                                      arguments: {
                                        "personId": contact.phones!
                                            .elementAt(0)
                                            .value
                                            .toString(),
                                      });
                                });
                              },
                              title: Text(contact.displayName!),
                              subtitle:
                                  Text(contact.phones!.elementAt(0).value!),
                              leading: (contact.avatar != null &&
                                      contact.avatar!.isNotEmpty)
                                  ? CircleAvatar(
                                      backgroundImage:
                                          MemoryImage(contact.avatar!),
                                    )
                                  : CircleAvatar(
                                      child: Text(contact.initials()),
                                    ),
                            );
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
