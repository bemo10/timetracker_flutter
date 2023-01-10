import 'package:flutter/material.dart';

class TaskFloatingActionButton extends StatelessWidget {
  late Function action;
  late bool active;

  TaskFloatingActionButton(
      {super.key, required this.action, required this.active});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:60,
      width:130,
      child: FloatingActionButton.extended(
        icon: (active == true
            ? const Icon(Icons.pause, size: 25,)
            : const Icon(Icons.play_arrow, size: 25,)),
        label: (active == true
            ? const Text("Stop", style: TextStyle(fontSize: 18))
            : const Text("Start", style: TextStyle(fontSize: 18))),
        onPressed: () => action(),
      ),
    );
  }
}
