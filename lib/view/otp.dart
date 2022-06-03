import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kathanote/model/auth.dart';
import 'package:provider/provider.dart';

class OtpPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const OtpPage({Key? key, required this.phoneNumber}) : super(key: key);
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    List<TextEditingController> controllerList =
        List.generate(6, (i) => TextEditingController());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            const Text("Verification code",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Text("We have send you a verification code to your number",
                style: TextStyle(color: Colors.black45)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
              child: OtpForm(textControllerList: controllerList),
            ),
            ElevatedButton(
              onPressed: () {
                String smsCode = "";

                for (var element in controllerList) {
                  smsCode += element.text.trim();
                }
                if (smsCode.length == 6) {
                  final authProvider =
                      Provider.of<AuthWithPhonenumber>(context, listen: false);
                  authProvider.verifySmsCode(context, smsCode);
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
    );
  }
}

class OtpForm extends StatelessWidget {
  const OtpForm({
    Key? key,
    required this.textControllerList,
  }) : super(key: key);
  final List<TextEditingController> textControllerList;
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 56,
            width: 52,
            child: TextField(
              controller: textControllerList[0],
              onChanged: (value) {
                if (value.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
              },
              style: const TextStyle(fontSize: 20),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          SizedBox(
            height: 56,
            width: 52,
            child: TextField(
              onChanged: (value) {
                if (value.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
                if (value.isEmpty) {
                  FocusScope.of(context).previousFocus();
                }
              },
              controller: textControllerList[1],
              style: const TextStyle(fontSize: 20),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          SizedBox(
            height: 56,
            width: 52,
            child: TextField(
              onChanged: (value) {
                if (value.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
                if (value.isEmpty) {
                  FocusScope.of(context).previousFocus();
                }
              },
              controller: textControllerList[2],
              style: const TextStyle(fontSize: 20),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          SizedBox(
            height: 56,
            width: 52,
            child: TextField(
              onChanged: (value) {
                if (value.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
                if (value.isEmpty) {
                  FocusScope.of(context).previousFocus();
                }
              },
              controller: textControllerList[3],
              style: const TextStyle(fontSize: 20),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          SizedBox(
            height: 56,
            width: 52,
            child: TextField(
              onChanged: (value) {
                if (value.length == 1) {
                  FocusScope.of(context).nextFocus();
                }
                if (value.isEmpty) {
                  FocusScope.of(context).previousFocus();
                }
              },
              controller: textControllerList[4],
              style: const TextStyle(fontSize: 20),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          SizedBox(
            height: 56,
            width: 52,
            child: TextField(
              onChanged: (value) {
                if (value.isEmpty) {
                  FocusScope.of(context).previousFocus();
                }
              },
              controller: textControllerList[5],
              style: const TextStyle(fontSize: 20),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
