import 'package:flutter/material.dart';

class CARDnofiticaton extends StatelessWidget {
  final void Function()? ondelet;
  final void Function()? onTAP;

  final String notification;
  final String title;

  const CARDnofiticaton({
    super.key,
    this.onTAP,
    this.ondelet,
    required this.notification,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        boxShadow: List.filled(
            4,
            BoxShadow(
                blurRadius: 1,
                color: Color.fromARGB(20, 149, 149, 149),
                spreadRadius: 4)),
        color: Color.fromARGB(255, 255, 252, 238),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // يجعل العمود يأخذ الحد الأدنى من الحجم بناءً على المحتوى
          crossAxisAlignment:
              CrossAxisAlignment.start, // لمحاذاة النصوص على اليسار
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Icon(
                  Icons.notification_important,
                  size: 40,
                  color: Colors.blue,
                ),
              ],
            ),
            const Divider(
              color: Colors.grey, // لون الخط
              thickness: 1, // سماكة الخط
            ),
            const SizedBox(height: 10), // مسافة صغيرة بين العناصر
            Text(
              notification,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 94, 94, 94),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
