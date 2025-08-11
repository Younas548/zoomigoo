import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  final String phoneNumber; // <-- Added this line

  const OtpScreen({super.key, required this.phoneNumber}); // <-- Constructor updated

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Phone verification',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your OTP code',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // OTP Input Fields
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) {
                setState(() {
                  otpCode = value;
                });
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeColor: Colors.grey,
                selectedColor: Colors.green,
                inactiveColor: Colors.grey.shade300,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            // Resend Code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Didn't receive code? ",
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  "Resend again",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final response = await http.post(
                    Uri.parse('http://YOUR_SERVER_IP:5000/api/auth/verify-otp'),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "phoneNumber": widget.phoneNumber,
                      "otp": otpCode
                    }),
                  );

                  if (response.statusCode == 200) {
                    print("OTP Verified");
                  } else {
                    print("Invalid OTP");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008955),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
