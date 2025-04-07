import 'package:flutter/material.dart';

class INKWALL extends StatelessWidget {
  final void Function()? navigator;
  final void Function()? onTAP;
  final String name;
  final Color color;
  final Color color2;
  final IconData? icon;

  const INKWALL({
    super.key,
    required this.name,
    this.icon,
    this.navigator,
    this.onTAP,
    required this.color,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTAP,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.blue,
                      size: width * 0.08,
                    ),
                    SizedBox(width: width * 0.03),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: color2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // أيقونة السهم
              IconButton(
                onPressed: navigator,
                icon: Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                  size: width * 0.06, // حجم الأيقونة يعتمد على عرض الشاشة
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
