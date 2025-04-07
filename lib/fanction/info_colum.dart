import 'package:flutter/material.dart';

class infoColum extends StatelessWidget {
  final double mywidth;
  final bool myBool;

  const infoColum({
    super.key,
    required this.myBool,
    required this.mywidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        infoTile(Icons.email, "Email", "abdo.saad.abd@gmail.com"),
        SizedBox(height: mywidth * 0.02),
        infoTile(Icons.phone, "Phone", "0121512854"),
        SizedBox(height: mywidth * 0.02),
        infoTile(Icons.person, "Username", "abdo.saad.abd"),
        SizedBox(height: mywidth * 0.02),
        infoTile(Icons.location_pin, "Location", "Egypt"),
      ],
    );
  }
}

Widget infoTile(IconData icon, String title, String subtitle) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
