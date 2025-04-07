import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class MyPinInput extends StatefulWidget {
  final TextEditingController mycontroller;

  const MyPinInput({super.key, required this.mycontroller});

  @override
  State<MyPinInput> createState() => _MyPinInputState();
}

class _MyPinInputState extends State<MyPinInput> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // الاتجاه من اليسار لليمين
      child: Pinput(
        controller: widget.mycontroller,
        length: 6,
        defaultPinTheme: PinTheme(
          width: 40,
          height: 40,
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.blue,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
