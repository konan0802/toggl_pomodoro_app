import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'TogglTask.dart';
import 'TaskTime.dart';
import 'TotalTaskInfo.dart';

class TaskInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TaskInfoState();
  }
}

class _TaskInfoState extends State<TaskInfo> {
  /// タイマー文字列用
  String _taskName = '';
  String _taskTimeMinutes = '';
  String _taskTimeSeconds = '';
  String _totalTaskHour = '';
  String _totalTaskMinutes = '';

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      fetchTogglTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 580.0,
      padding: EdgeInsets.only(top: 11, left: 10, right: 10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "> " + _taskName,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 55,
              ),
              Container(
                width: 290.0,
                child: TaskTime(_taskTimeMinutes, _taskTimeSeconds),
              ),
              TotalTaskInfo(),
            ],
          )
        ],
      ),
    );
  }

  Future<void> fetchTogglTask() async {
    String url = 'https://api.track.toggl.com/api/v8/time_entries/current';
    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Authorization": 'Basic ' +
          base64Encode(utf8.encode(dotenv.env['TOGGL_API_KEY']! + ':api_token'))
    });
    if (response.statusCode == 200) {
      TogglTask togglTask =
          TogglTask.fromJson(jsonDecode(response.body)["data"]);

      // タスク経過時間 = 現在の時刻 - タスクの開始時刻
      var now = DateTime.now();
      var start = DateTime.parse(togglTask.start);
      var duration = now.difference(start).inSeconds;
      var durationM = duration ~/ 60;
      var durationS = duration % 60;
      setState(() {
        _taskTimeMinutes = durationM.toString();
        _taskTimeSeconds = durationS.toString();
        _taskName = togglTask.description;
      });
    } else {
      throw Exception('Failed to load toggl');
    }
  }

/*
  Future<void> fetchTogglTotalTask(String lastmonth, String taskName) async {
    String url = 'https://api.track.toggl.com/reports/api/v2/details';
    url +=
        '?workspace_id=${dotenv.env['WORKSPACE_ID']}&since=${lastmonth}&user_agent=konanforbis@gmail.com&description=${taskName}';
    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Authorization": 'Basic ' +
          base64Encode(
              utf8.encode(dotenv.env['TOGGL_API_KEY']! + ':api_token'))
    });
    if (response.statusCode == 200) {
      TogglTask togglTask =
          TogglTask.fromJson(jsonDecode(response.body)["data"]);

      // タスク経過時間 = 現在の時刻 - タスクの開始時刻
      var now = DateTime.now();
      var start = DateTime.parse(togglTask.start);
      var duration = now.difference(start).inSeconds;
      var durationM = duration ~/ 60;
      var durationS = duration % 60;
      setState(() {
        _taskTimeMinutes = durationM.toString();
        _taskTimeSeconds = durationS.toString();
        _taskName = togglTask.description;
      });
    } else {
      throw Exception('Failed to load toggl');
    }
  }
  */
}
