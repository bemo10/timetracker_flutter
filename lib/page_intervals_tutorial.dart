/*
import 'package:flutter/material.dart';
import 'package:timetracker_flutter/tree.dart' as Tree hide getTree;
// to avoid collision with an Interval class in another library
import 'package:timetracker_flutter/requests.dart';
import 'dart:async';


class PageIntervals extends StatefulWidget {
  int id;

  PageIntervals({super.key, required this.id});

  @override
  _PageIntervalsState createState() => _PageIntervalsState();
}

class _PageIntervalsState extends State<PageIntervals> {
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

  Widget _buildRow(Tree.Interval interval, int index) {
    String strDuration = Duration(seconds: interval.duration).toString().split('.').first;
    String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = interval.finalDate.toString().split('.')[0];
    return ListTile(
      title: Text('from ${strInitialDate} to ${strFinalDate}'),
      trailing: Text('$strDuration'),
    );
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }
}

*/