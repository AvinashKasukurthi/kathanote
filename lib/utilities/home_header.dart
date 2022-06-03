import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final users = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots();
    return Container(
      alignment: Alignment.topLeft,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: const BoxDecoration(color: Colors.blueAccent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Good Morning",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IntrinsicHeight(
                child: StreamBuilder<DocumentSnapshot>(
              stream: users,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong!"),
                  );
                }
                final data = snapshot.data;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "You Gave",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              data!.data().toString().contains("youGave")
                                  ? "₹ ${data['youGave']}"
                                  : "₹ 0",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    const VerticalDivider(
                      color: Colors.black,
                    ),
                    Column(
                      children: [
                        const Text(
                          "You Got",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            data.data().toString().contains("youGot")
                                ? "₹ ${data['youGot']}"
                                : "₹ 0",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
