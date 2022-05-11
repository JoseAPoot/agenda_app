import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextEditingController? textEditingController;

  const Input({
    Key? key,
    required this.hintText,
    required this.prefixIcon,
    this.textEditingController,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        keyboardType: keyboardType,
        controller: textEditingController,
        textCapitalization: textCapitalization,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: Icon(prefixIcon, color: Theme.of(context).primaryColor),
          prefixIconConstraints: const BoxConstraints(minWidth: 60.0),
        ),
      ),
    );
  }
}
