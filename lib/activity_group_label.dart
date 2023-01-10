import 'package:flutter/material.dart';



class ActivityGroupLabel extends StatelessWidget {
  final String text;

  const ActivityGroupLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 40,
          ),

        ),
      ),
    );
  }
}
