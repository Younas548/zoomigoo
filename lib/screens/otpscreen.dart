import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpCode = '';
  bool isLoading = false;
  bool isResending = false;
  int resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    setState(() => resendSeconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds > 0) {
        setState(() => resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit OTP")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/auth/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": widget.phoneNumber,
          "otp": otpCode
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ OTP Verified Successfully")),
        );
        // TODO: Navigate to home screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Invalid OTP: ${data['error'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Error verifying OTP")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resendOtp() async {
    if (resendSeconds > 0) return; // Prevent tapping before cooldown ends

    setState(() {
      isResending = true;
      resendSeconds = 30; // Reset timer
    });
    startCountdown();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/auth/send-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": widget.phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("📩 OTP Resent Successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠ Failed to resend: ${data['error'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      print("Error resending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Error resending OTP")),
      );
    } finally {
      setState(() => isResending = false);
    }
  }

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
              'Phone Verification',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your OTP code',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) => otpCode = value,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive code? ",
                  style: TextStyle(color: Colors.black54),
                ),
                GestureDetector(
                  onTap: (resendSeconds == 0 && !isResending) ? resendOtp : null,
                  child: Text(
                    resendSeconds > 0
                        ? "Resend in ${resendSeconds}s"
                        : (isResending ? "Resending..." : "Resend again"),
                    style: TextStyle(
                      color: (resendSeconds == 0 && !isResending)
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008955),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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
