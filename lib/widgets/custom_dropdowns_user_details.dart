import 'package:flutter/material.dart';

class CustomDropdownUserDetails extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const CustomDropdownUserDetails({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
