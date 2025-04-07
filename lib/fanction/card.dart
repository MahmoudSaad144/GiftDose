import 'package:flutter/material.dart';

class CARD extends StatelessWidget {
  final void Function()? onTAP;
  final ImageProvider<Object> imageProvider;
  final String title;
  final String subtitle;

  const CARD({
    super.key,
    this.onTAP,
    required this.title,
    required this.subtitle,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTAP,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: height * 0.01,
          horizontal: width * 0.02,
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 248, 226),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: width * 0.18, // العرض النسبي للصورة
                height: width * 0.18, // الارتفاع النسبي للصورة
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageProvider,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
