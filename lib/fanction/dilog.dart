import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final dynamic dilogicon;
  final void Function()? onPressed1;
  final void Function()? onPressed2;
  final double? fontsize;
  final Color? dilogiconcolor;
  final String? titledilog;
  final Color? Colortitle;
  final String? contentdilog;
  final Widget? content;
  final String? namebottomdilog1;
  final String? namebottomdilog2;

  const CustomDialog({
    super.key,
    this.dilogicon,
    this.dilogiconcolor,
    this.titledilog,
    this.contentdilog,
    this.namebottomdilog1,
    this.namebottomdilog2 = "",
    this.fontsize,
    this.Colortitle,
    this.onPressed1,
    this.onPressed2,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    // Controller لـ PinInput

    return AlertDialog(
      icon: dilogicon,
      iconColor: dilogiconcolor!,
      title: Center(
        child: Text(
          titledilog!,
          style: TextStyle(
              fontSize: fontsize,
              color: Colortitle,
              fontWeight: FontWeight.w400),
        ),
      ),
      content: content,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: MaterialButton(
                onPressed: onPressed1,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      namebottomdilog1!,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            if (namebottomdilog2 != null && namebottomdilog2!.isNotEmpty)
              Expanded(
                child: MaterialButton(
                  onPressed: onPressed2,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        namebottomdilog2!,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
