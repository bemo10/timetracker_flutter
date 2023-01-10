import 'package:flutter/material.dart';

class ProjectFloatingActionButton extends StatelessWidget {
  late Function action;

  ProjectFloatingActionButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => action(),
    );
  }
}
