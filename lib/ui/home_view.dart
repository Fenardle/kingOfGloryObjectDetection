import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/tflite/recognition.dart';
import 'package:object_detection/tflite/stats.dart';
import 'package:object_detection/ui/box_widget.dart';
import 'package:object_detection/ui/camera_view_singleton.dart';

import 'camera_view.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class Victory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Victory"),
      ),
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('getRewardRTT'),
        ),
      ),
    );
  }
}

class Defeat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Defeat"),
      ),
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('burnRTT'),
        ),
      ),
    );
  }
}

class _HomeViewState extends State<HomeView> {
  /// Results to draw bounding boxes
  List<Recognition> results;

  /// Realtime stats
  Stats stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState()
  {
    results = [];
  }

  @override
  Widget build(BuildContext context) {
    if(results.indexWhere((f) => f.label == 'Victory') != -1){
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Victory()),
      );}
    else if(results.indexWhere((f) => f.label == 'Defeat') != -1){
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Defeat()),
      );}
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          // Camera View
          CameraView(resultsCallback, statsCallback),

          // Bounding boxes
          boundingBoxes(results),

          // Heading
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'De-Battle Recognition System',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent.withOpacity(0.6),
                ),
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (_, ScrollController scrollController) => Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BORDER_RADIUS_BOTTOM_SHEET),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up,
                            size: 48, color: Colors.orange),
                        (stats != null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    StatsRow('Inference time:',
                                        '${stats.inferenceTime} ms'),
                                    StatsRow('Total prediction time:',
                                        '${stats.totalElapsedTime} ms'),
                                    StatsRow('Pre-processing time:',
                                        '${stats.preProcessingTime} ms'),
                                    StatsRow('Frame',
                                        '${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}'),
                                  ],
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    if (results == null) {
      return Container();
    }

    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left), Text(right)],
      ),
    );
  }
}
