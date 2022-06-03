import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kathanote/view/home.dart';
import 'package:kathanote/view/login.dart';

class AuthWithPhonenumber with ChangeNotifier {
  String? _verificationId;

  Future<void> verifyMobileNumber(
      BuildContext context, String phoneNumber) async {
    var auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: "+91$phoneNumber",
      verificationCompleted: (PhoneAuthCredential credential) {
        auth.signInWithCredential(credential).then(
          (UserCredential userCredential) {
            if (userCredential.user != null) {
              Navigator.pushNamed(context, "home");
            }
          },
        ).onError((error, stackTrace) {
          Navigator.pushReplacementNamed(context, Login.route);
        });
      },
      verificationFailed: (FirebaseAuthException verificationException) {},
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        notifyListeners();
      },
      timeout: const Duration(seconds: 60),
    );
    notifyListeners();
  }

  void verifySmsCode(BuildContext context, String smsCode) {
    var auth = FirebaseAuth.instance;
    PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: smsCode);

    auth
        .signInWithCredential(authCredential)
        .then((value) => Navigator.pushReplacementNamed(context, Home.route))
        .onError((error, stackTrace) =>
            Navigator.pushReplacementNamed(context, Login.route));
  }
}
