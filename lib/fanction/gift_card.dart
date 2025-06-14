import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftCard extends StatefulWidget {
  final String image;
  final String? color;

  final String? location;
  final String? size;
  final String productName;
  final String? purchasedStatus;
  final String productDescription;
  final String? price;
  final String? currency;
  final bool isUserProduct;
  final bool isActive; // ✅ تمرير حالة النشاط
  final Function(bool)? onStatusChanged; // ✅ إضافة كولباك لتغيير الحالة
  final void Function()? onPressed;
  final void Function()? onPressed2;

  const GiftCard({
    required this.image,
    required this.color,
    required this.location,
    required this.size,
    required this.productName,
    required this.productDescription,
    required this.price,
    this.isUserProduct = false,
    this.isActive = false, // ✅ قيمة افتراضية
    this.onStatusChanged,
    this.onPressed,
    this.onPressed2,
    required this.currency,
    this.purchasedStatus,
  });

  @override
  State<GiftCard> createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  late bool isActive;
  @override
  void initState() {
    super.initState();
    isActive = widget.isActive; // ✅ تحميل الحالة الأولية من widget
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.image,
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.2,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'images/GTIF.jpg',
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.1,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                if (widget.purchasedStatus !=
                    null) // ✅ إظهار الشريط فقط إذا لم يكن null
                  Positioned(
                    top: 10, // يتحكم في موضع الشريط من الأعلى
                    left: 0,
                    right: 0,
                    child: Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.7), // لون أخضر شفاف
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.purchasedStatus!, // ✅ عرض النص القادم من API
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${'name'.tr}:${widget.productName}".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${'color'.tr}: ${widget.color ?? "No data available.".tr}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${'Size'.tr}:  ${widget.size ?? "No data available.".tr}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${'location'.tr}: ${widget.location ?? "No data available.".tr}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${'price'.tr}: ${widget.price ?? ""} (${widget.currency})"
                            .tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.isUserProduct)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ زر تبديل الحالة فقط إذا كان المنتج يخص المستخدم
                      if (widget.isUserProduct)
                        Row(
                          children: [
                            Text(
                              isActive
                                  ? "Hide".tr
                                  : "Hide".tr, // ✅ تغيير النص حسب الحالة
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: !isActive,
                              onChanged: (value) {
                                setState(() {
                                  isActive = !value;
                                });
                                widget.onStatusChanged?.call(value);
                              },
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.productDescription,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (widget.isUserProduct)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      onPressed: widget.onPressed2,
                      child: Container(
                        height: 40,
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(255, 43, 119, 182)
                                  .withOpacity(1),
                              const Color.fromARGB(255, 86, 155, 211)
                                  .withOpacity(1),
                              const Color.fromARGB(255, 121, 195, 255)
                                  .withOpacity(1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Edit'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      onPressed: widget.onPressed,
                      child: Container(
                        height: 40,
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 182, 43, 43).withOpacity(1),
                              Color.fromARGB(255, 211, 86, 86).withOpacity(1),
                              Color.fromARGB(255, 255, 121, 121).withOpacity(1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Delete'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.isUserProduct == false)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      onPressed: widget.onPressed,
                      child: Container(
                        height: 40,
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 182, 43, 43).withOpacity(1),
                              Color.fromARGB(255, 211, 86, 86).withOpacity(1),
                              Color.fromARGB(255, 255, 121, 121).withOpacity(1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
