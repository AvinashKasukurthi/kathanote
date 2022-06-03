import 'package:flutter/material.dart';
import 'package:kathanote/model/auth.dart';
import 'package:kathanote/view/otp.dart';
import 'package:provider/provider.dart';

import '../utilities/text_field_with_label.dart';

class Login extends StatelessWidget {
  static const route = '/login';
  Login({Key? key}) : super(key: key);

  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 15.0),
                    child: TextFieldWithLabel(
                        phoneNumberController: _phoneNumberController),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_phoneNumberController.text.trim().length == 10) {
                        final authProvider = Provider.of<AuthWithPhonenumber>(
                            context,
                            listen: false);
                        authProvider.verifyMobileNumber(
                            context, _phoneNumberController.text.trim());
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpPage(
                                  phoneNumber:
                                      _phoneNumberController.text.trim()),
                            ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Let's Go",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
