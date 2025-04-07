import 'package:flutter/material.dart';

bool _isLoading = true;

class CustomDialog extends StatefulWidget {
  final String titledilog;
  final double? fontsize;
  final Color? Colortitle;
  final String? contentdilog;
  final String? namebottomdilog1;
  final Color? dilogiconcolor;
  final IconData? dilogicon;
  final VoidCallback? onPressed1;
  final VoidCallback? onResend; // ⬅️ دالة إعادة الإرسال
  final Widget? content;

  const CustomDialog({
    required this.titledilog,
    this.fontsize,
    this.Colortitle,
    this.contentdilog,
    this.namebottomdilog1,
    this.dilogiconcolor,
    this.dilogicon,
    this.onPressed1,
    this.onResend, // ⬅️ استلام الدالة هنا
    this.content,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  void initState() {
    super.initState();
    _startTimer(); // تشغيل المؤقت عند فتح الديالوج
  }

  @override
  void dispose() {
    // التأكد من إيقاف التايمر عند الخروج
    super.dispose();
  }

  /// دالة بدء المؤقت
  void _startTimer() {
    setState(() {});
  }

  /// تنفيذ إرسال الكود مع اللودينج
  void _handleSend() async {
    setState(() {
      _isLoading = true; // ✅ تفعيل اللودينج
    });

    await Future.delayed(Duration(seconds: 5)); // محاكاة تأخير الإرسال

    widget.onPressed1?.call(); // استدعاء الدالة الأصلية

    setState(() {
      _isLoading = false; // ❌ إيقاف اللودينج بعد انتهاء العملية
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      textDirection: TextDirection.ltr,
      children: [
        AlertDialog(
          title: Center(
            child: Text(
              widget.titledilog,
              style: TextStyle(
                fontSize: widget.fontsize ?? 18,
                color: widget.Colortitle ?? Colors.black,
              ),
            ),
          ),
          content: widget.content ??
              (widget.contentdilog != null
                  ? Text(widget.contentdilog!, style: TextStyle(fontSize: 16))
                  : null),
          actions: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : _handleSend, // ✅ تعطيل الزر أثناء اللودينج
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 43, 119, 182),
                              Color.fromARGB(255, 86, 155, 211),
                              Color.fromARGB(255, 121, 195, 255),
                            ],
                          ),
                        ),
                        child: Center(
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white) // ✅ إظهار اللودينج
                              : Text(widget.namebottomdilog1 ?? "",
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          icon: widget.dilogicon != null
              ? Icon(widget.dilogicon,
                  color: widget.dilogiconcolor ?? Colors.black, size: 100)
              : null,
        ),
      ],
    );
  }
}
