import 'package:flutter/material.dart';

class OnErrorWidget extends StatelessWidget {
  const OnErrorWidget(
      {super.key, required this.onPressed, required this.message});
  final Function() onPressed;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          ElevatedButton(onPressed: onPressed(), child: const Text("Retry"))
        ],
      ),
    );
  }
}
