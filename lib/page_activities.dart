import 'package:flutter/material.dart';
import 'package:timetracker_flutter/tree.dart' as Tree hide getTree;
import 'package:timetracker_flutter/page_intervals.dart';
import 'package:timetracker_flutter/requests.dart';
import 'dart:async';
import 'package:timetracker_flutter/activity_group_label.dart';
import 'package:timetracker_flutter/activity_info.dart';
import 'package:timetracker_flutter/task_floating_action_button.dart';
import 'package:timetracker_flutter/project_floating_action_button.dart';
import 'package:timetracker_flutter/page_create_activity.dart';

class PageActivities extends StatefulWidget {
  late int id;

  PageActivities({super.key, required this.id});

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late Future<Tree.Tree> futureTree;

  late Timer _timer;
  static const int periodeRefresh = 6;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree.Tree>(
      future: futureTree,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Current root node data
          String activityType = (snapshot.data!.root is Tree.Project?"project":"task");
          String? initialDate =
              snapshot.data!.root.initialDate.toString().split('.')[0];
          String? finalDate =
              snapshot.data!.root.finalDate.toString().split('.')[0];
          String duration = Duration(seconds: snapshot.data!.root.duration)
              .toString()
              .split('.')
              .first;

          // Group children into types
          List<Tree.Project> childrenProjects = snapshot.data!.root.children
              .whereType<Tree.Project>()
              .toList()
              .cast<Tree.Project>();
          List<Tree.Task> childrenTasks = snapshot.data!.root.children
              .whereType<Tree.Task>()
              .toList()
              .cast<Tree.Task>();
          List<Tree.Interval> childrenIntervals = snapshot.data!.root.children
              .whereType<Tree.Interval>()
              .toList()
              .cast<Tree.Interval>();

          // Sort activities from most to least recent
          childrenProjects.sort((a, b) => a.finalDate == null
              ? 1
              : b.finalDate == null
                  ? -1
                  : b.finalDate!.compareTo(a.finalDate!));
          childrenTasks.sort((a, b) => a.finalDate == null
              ? 1
              : b.finalDate == null
                  ? -1
                  : b.finalDate!.compareTo(a.finalDate!));
          childrenIntervals.sort((a, b) => a.finalDate == null
              ? 1
              : b.finalDate == null
                  ? -1
                  : b.finalDate!.compareTo(a.finalDate!));

          // Construct list with all groups of children and get starting index for each group
          List children = [
            ...childrenProjects,
            ...childrenTasks,
            ...childrenIntervals
          ];
          int childrenProjectsIndex = 0;
          int childrenTasksIndex = childrenProjects.length;
          int childrenIntervalsIndex =
              childrenProjects.length + childrenTasks.length;

          return Scaffold(
            appBar: AppBar(
                title: Text(snapshot.data!.root.name == "root"
                    ? "home"
                    : snapshot.data!.root.name!),
                actions: <Widget>[
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () => _showInfoDialog(
                        initialDate: initialDate,
                        finalDate: finalDate,
                        duration: duration),
                    icon: Icon(Icons.info),
                  ),
                  IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () {
                        while (Navigator.of(context).canPop()) {
                          print("pop");
                          Navigator.of(context).pop();
                          //PageActivities(id:0);
                        }
                      }),
                ]),
            body: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: children.length,
              itemBuilder: (BuildContext context, int index) => _buildRow(
                  children[index],
                  index,
                  childrenProjectsIndex,
                  childrenTasksIndex,
                  childrenIntervalsIndex),
            ),
            floatingActionButton:
                _switchFloatingActionButton(activityType, snapshot.data!.root),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // Default
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Tree.Activity activity, int index, int childrenProjectsIndex,
      int childrenTasksIndex, int childrenIntervalsIndex) {
    String strInitialDate = activity.initialDate.toString().split('.')[0];
    String strFinalDate = activity.finalDate.toString().split('.')[0];
    String strDuration =
        Duration(seconds: activity.duration).toString().split('.').first;
    assert(activity is Tree.Project ||
        activity is Tree.Task ||
        activity is Tree.Interval);

    if (activity is Tree.Project) {
      // Projects
      activity = activity as Tree.Project;
      return Column(
        children: [
          if (index == childrenProjectsIndex) ...[
            const ActivityGroupLabel(text: "Projects"),
          ],
          Card(
            elevation: 2,
            margin: EdgeInsets.all(5),
            child: ListTile(
              leading: Icon(Icons.folder),
              title: Text('${activity.name}'),
              subtitle: Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children: [
                      Icon(Icons.access_time),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                      ),
                      Text(
                        '$strDuration',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  )),
              minVerticalPadding: 15,
              onTap: () => _navigateDownActivities(activity.id),
              onLongPress: () => _showInfoDialog(
                  initialDate: strInitialDate,
                  finalDate: strFinalDate,
                  duration: strDuration),
            ),
          ),
        ],
      );
    } else if (activity is Tree.Task) {
      // Tasks
      activity = activity as Tree.Task;
      return Column(
        children: [
          if (index == childrenTasksIndex) ...[
            const ActivityGroupLabel(text: "Tasks"),
          ],
          Card(
            elevation: 2,
            margin: EdgeInsets.all(5),
            child: ListTile(
              leading: Icon(Icons.task),
              title: Text('${activity.name}'),
              subtitle: Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children: [
                      Icon(Icons.access_time),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                      ),
                      Text(
                        '$strDuration',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  )),
              trailing: Visibility(
                  visible: activity.active,
                  child: const Icon(
                    Icons.play_circle_filled,
                    color: Colors.green,
                  )),
              minVerticalPadding: 15,
              onTap: () => _navigateDownActivities(activity.id),
              onLongPress: () {
                _showInfoDialog(
                    initialDate: strInitialDate,
                    finalDate: strFinalDate,
                    duration: strDuration);
              },
            ),
          ),
        ],
      );
    } else {
      // Intervals
      activity = activity as Tree.Interval;
      return Column(
        children: [
          if (index == childrenIntervalsIndex) ...[
            const ActivityGroupLabel(text: "Intervals"),
          ],
          Card(
            elevation: 2,
            margin: EdgeInsets.all(5),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),),
                  const Text(
                    'From',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${strInitialDate}',
                        style: const TextStyle(fontSize: 16),
                      )),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  ),
                  const Text(
                    'To',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${strFinalDate}',
                        style: TextStyle(fontSize: 16),
                      )),
                  //Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),),
                ],
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.access_time),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Text(
                    '$strDuration',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              trailing: Visibility(
                  visible: activity.active,
                  child: const Icon(
                    Icons.play_circle_filled,
                    color: Colors.green,
                  )),
              minVerticalPadding: 15,
            ),
          ),
        ],
      );
    }
  }

  void _navigateDownActivities(int childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(id: childId),
    ))
        .then((var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _showActivityCreatePage() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageCreateActivity(
        parentId: id,
        refreshCallback: () => _refresh(),
      ),
    ));
  }

  /*void _navigateDownIntervals(int childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
        builder: (context) => PageIntervals(id: childId),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }*/

  void _refresh() async {
    futureTree = getTree(id);
    setState(() {});
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  Future<dynamic> _showInfoDialog(
      {required String? initialDate,
      required String? finalDate,
      required String duration}) {
    return showDialog(
        context: context,
        builder: (context) => ActivityInfo(
            initialDate: initialDate,
            finalDate: finalDate,
            duration: duration));
  }

  Widget _switchFloatingActionButton(String type, Tree.Activity activity) {
    Widget fab = Container();

    switch (type) {
      case "task":
        fab = TaskFloatingActionButton(
          action: () {
            if ((activity as Tree.Task).active) {
              stop(activity.id);
              _refresh();
              /*futureTree = getTree(id);
              _refresh();*/
              final snackBar = SnackBar(
                content: const Text('Task stopped!'),
                duration: const Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'Ok',
                  onPressed: () {},
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              start(activity.id);
              _refresh();
              /*futureTree = getTree(id);
              _refresh();*/
              final snackBar = SnackBar(
                content: const Text('Task started!'),
                duration: const Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'Ok',
                  onPressed: () {},
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          active: (activity as Tree.Task).active,
        );
        break;
      case "project":
        fab = ProjectFloatingActionButton(
          action: () {
            _showActivityCreatePage();
          },
        );
        break;
    }

    return fab;
  }
}
