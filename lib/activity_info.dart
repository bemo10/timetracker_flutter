import 'package:flutter/material.dart';

class ActivityInfo extends StatelessWidget {
  final String? initialDate;
  final String? finalDate;
  final String duration;

  ActivityInfo(
      {super.key,
      required this.initialDate,
      required this.finalDate,
      required this.duration});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline),
          Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),),
          const Text("Details"),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),),
          const Text('From', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
          Align (
              alignment: Alignment.centerRight,
              child: Text((initialDate!="null"?'${initialDate}':"Not available"), style: TextStyle(fontSize: 18),)
          ),
          Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),),
          const Text('To', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
          Align(
              alignment: Alignment.centerRight,
              child: Text((finalDate!="null"?'${finalDate}':"Not available"), style: TextStyle(fontSize: 18),)
          ),
          Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),),
          const Text('Duration', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
          Align(
              alignment: Alignment.centerRight,
              child: Text('${duration}', style: TextStyle(fontSize: 18),)
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context, 'Ok'),
            child: const Text("Ok"))
      ],
    );
  }
}
