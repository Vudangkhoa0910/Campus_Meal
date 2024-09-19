import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/screens/userType_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerifyOtp extends StatefulWidget {
  final String verificationId; //nhan verify

  const VerifyOtp({Key? key, required this.verificationId}) : super(key: key);

  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {  
  final FirebaseAuth auth = FirebaseAuth.instance;
  String code = ""; // luu OTP

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
          fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFC8019)),
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFFFFF2E0)),
    );

    return Scaffold(
      backgroundColor: Color(0xFFFFFEF6),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    color: Color(0xFFFC8019),
                  )),
            ),
            const SizedBox(
              height: 64,
            ),
            Text(
              "OTP Verification",
              style: AppTypography.textMd
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              "Enter the six digit code which has been \nsent to your mobile number +91xxxxxxxxxx.",
              style: AppTypography.textSm.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                showCursor: true,
                onCompleted: (value) {
                  setState(() {
                    code = value;
                  });
                }),
            const SizedBox(
              height: 12,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  // Xử lý gửi lại OTP nếu cần
                  // Bạn có thể gọi lại verifyPhoneNumber ở đây nếu muốn
                },
                child: Text(
                  "Resend OTP",
                  style: AppTypography.textSm.copyWith(fontSize: 14),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                if (code.isNotEmpty) {
                  try {
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: widget.verificationId, smsCode: code);
                    await auth.signInWithCredential(credential);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const UserType()),
                    );
                  } catch (e) {
                    print("Wrong OTP: $e");// thong bao loi nguoi dung
                  }
                } else {
                  print("OTP code is empty");
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffF57C51),
                      ),
                      child: Center(
                        child: Text("Proceed",
                            style: AppTypography.textMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
