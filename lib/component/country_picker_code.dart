import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class CountryCodePickerField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(String)? onCountryCodeChanged;

  const CountryCodePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.onCountryCodeChanged,
  });

  @override
  State<CountryCodePickerField> createState() => _CountryCodePickerFieldState();
}

class _CountryCodePickerFieldState extends State<CountryCodePickerField> {
  String selectedPhoneCode = "+965"; // default Kuwait

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Enter Phone Number".tr;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUnfocus,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              exclude: ['IL'],
              onSelect: (Country country) {
                setState(() {
                  selectedPhoneCode = "${country.phoneCode}";
                  if (widget.onCountryCodeChanged != null) {
                    widget.onCountryCodeChanged!(selectedPhoneCode);
                  }
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              selectedPhoneCode,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
