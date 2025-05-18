import 'dart:async';
import 'package:giftdose/Controller/token.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  double opacity1 = 0;
  double opacity2 = 0;
  double opacity3 = 0;
  double opacity4 = 0;
  double space = 0;
  double bottomPadding = 0; // للتحكم في حركة الجملة للأعلى

  Future<void> _checkLoginStatus() async {
    Future.delayed(Duration(seconds: 2), () {
      TokenService.checkAuthStatus();
    });
  }

  @override
  void initState() {
    super.initState();

    // التأثيرات الخاصة
    Timer(const Duration(milliseconds: 500), () {
      setState(() => opacity1 = 1);
    });
    Timer(const Duration(milliseconds: 1000), () {
      setState(() => opacity2 = 1);
    });
    Timer(const Duration(milliseconds: 1500), () {
      setState(() => space = 20);
    });
    Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        opacity3 = 1;
        bottomPadding = 20; // تحريك الجملة للأعلى بشكل ناعم
      });
    });
    Timer(const Duration(milliseconds: 2000), () {
      setState(() => opacity4 = 1);
    });

    // بعد 6 ثواني، تحقق من حالة تسجيل الدخول
    Timer(const Duration(seconds: 6), () {
      _checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;

            return Container(
              height: height,
              width: width,
              decoration: const BoxDecoration(
                color: Color(0xFFF9EFC7),
              ),
              child: Stack(
                children: [
                  // الخلفية المتدرجة
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.9),
                          Colors.black.withOpacity(.8),
                          Colors.black.withOpacity(.6),
                        ],
                      ),
                    ),
                  ),

                  // المحتوى الرئيسي في المنتصف
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity1,
                              child: FittedBox(
                                child: Text(
                                  "Gift",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.12,
                                    fontFamily: "Caveat",
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity2,
                              child: SizedBox(width: space),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity3,
                              child: Image.asset(
                                "images/logo.png",
                                height: height * 0.1,
                                width: height * 0.1,
                                fit: BoxFit.cover,
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity2,
                              child: SizedBox(width: space),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity2,
                              child: FittedBox(
                                child: Text(
                                  "Dose",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.12,
                                    fontFamily: "Caveat",
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // الجملة أسفل الشاشة بتأثير جمالي
                  Positioned(
                    bottom: height * 0.37, // يجعلها قريبة من الحافة السفلية
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(seconds: 4),
                      opacity: opacity4,
                      child: AnimatedPadding(
                        duration: const Duration(seconds: 3),
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: Center(
                          child: Text(
                            "Dose of happiness",
                            style: TextStyle(
                              fontSize: width * 0.08,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Caveat",
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(3, 3),
                                )
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
