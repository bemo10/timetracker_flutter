import 'package:flutter/material.dart';
import 'package:timetracker_flutter/requests.dart';

enum ActivityType { project, task }

class PageCreateActivity extends StatefulWidget {
  late int parentId;
  late Function refreshCallback;
  PageCreateActivity({super.key, required this.parentId, required this.refreshCallback});

  @override
  State<PageCreateActivity> createState() => _PageCreateActivityState();
}

class _PageCreateActivityState extends State<PageCreateActivity> {
  late int parentId;
  late Function refreshCallback;
  ActivityType? _activityType = ActivityType.project;
  final TextEditingController activityNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    parentId = widget.parentId;
    refreshCallback = widget.refreshCallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Activity"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (!activityNameController.text.isEmpty) {
                if (_activityType == ActivityType.project) {
                  createProject(parentId, activityNameController.text);

                  final snackBar = SnackBar(
                    content: const Text('Project created!'),
                    duration: const Duration(seconds: 1),
                    action: SnackBarAction(
                      label: 'Ok',
                      onPressed: () {},
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  createTask(parentId, activityNameController.text);

                  final snackBar = SnackBar(
                    content: const Text('Task created!'),
                    duration: const Duration(seconds: 1),
                    action: SnackBarAction(
                      label: 'Ok',
                      onPressed: () {},
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                // Refresh parent and go back
                refreshCallback();
                Navigator.of(context).pop();
              } else {
                final snackBar = SnackBar(
                  content: const Text('Name is empty!'),
                  action: SnackBarAction(
                    label: 'Ok',
                    onPressed: () {},
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: TextField(
              controller: activityNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Activity name',
              ),
            ),
          ),
          ListTile(
            title: const Text("Project"),
            leading: Radio<ActivityType>(
              value: ActivityType.project,
              groupValue: _activityType,
              onChanged: (ActivityType? value) {
                setState(() {
                  _activityType = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text("Task"),
            leading: Radio<ActivityType>(
              value: ActivityType.task,
              groupValue: _activityType,
              onChanged: (ActivityType? value) {
                setState(() {
                  _activityType = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
