import 'package:flutter/material.dart';

class TextFieldWithLabel extends StatelessWidget {
  const TextFieldWithLabel({
    Key? key,
    required TextEditingController phoneNumberController,
  })  : _phoneNumberController = phoneNumberController,
        super(key: key);

  final TextEditingController _phoneNumberController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your mobile number',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          maxLength: 10,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "+91",
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          controller: _phoneNumberController,
        ),
      ],
    );
  }
}
