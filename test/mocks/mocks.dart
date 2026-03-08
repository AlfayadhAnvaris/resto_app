// test/mocks/mocks.dart

import 'package:mockito/annotations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  Permission,
])
void main() {}