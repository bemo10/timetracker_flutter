import 'package:flutter/material.dart';
import 'package:timetracker_app/tree.dart' hide getTree;
import 'package:timetracker_app/page_intervals.dart';
import 'package:timetracker_app/requests.dart';
import 'dart:async';


class PageActivities extends StatefulWidget {
  late int id;

  PageActivities({super.key, required this.id});

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late Future<Tree> futureTree;

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
    return FutureBuilder<Tree>(
        future: futureTree,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(
                    title: Text(snapshot.data!.root.name),
                    actions: <Widget>[
                      IconButton(icon: Icon(Icons.home),
                          onPressed: () {
                            while(Navigator.of(context).canPop()) {
                              print("pop");
                              Navigator.of(context).pop();
                              //PageActivities(id:0);
                            }
                          }
                      ),
                      //TODO other actions
                    ]
                ),
                body: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.root.children.length,
                  itemBuilder: (BuildContext context, int index) => _buildRow(snapshot.data!.root.children[index], index),
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                )
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
            )
          );
        },
    );




  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    assert (activity is Project || activity is Task);

    if (activity is Project) {
      return ListTile(
        title: Text('${activity.name}'),
        trailing: Text('$strDuration'),
        onTap: () => _navigateDownActivities(activity.id),
      );
    } else {
      Task task = activity as Task;
      Widget trailing;
      trailing = Text('$strDuration');
      return ListTile(
        title: Text('${activity.name}'),
        trailing: trailing,
        onTap: () => _navigateDownIntervals(activity.id),
        onLongPress: () {
          if ((activity as Task).active) {
            stop(activity.id);
            _refresh();
          } else {
            start(activity.id);
            _refresh();
          }
        },
      );
    }
  }

  void _navigateDownActivities(int childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
        builder: (context) => PageActivities(id: childId),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _navigateDownIntervals(int childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
        builder: (context) => PageIntervals(id: childId),
    )).then( (var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }
}

