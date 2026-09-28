import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'location_task_handler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}
