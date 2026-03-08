// test/mocks/mock_permission_handler.dart

import 'package:permission_handler/permission_handler.dart';

// Mock class untuk Permission
class MockPermission {
  static Future<bool> get isGranted async => true;
  static Future<bool> get isDenied async => false;
  static Future<bool> get isPermanentlyDenied async => false;
  static Future<bool> get isRestricted async => false;
  static Future<bool> get isLimited async => false;
  static Future<bool> get isProvisional async => false;
}

// Mock class untuk PermissionStatus
class MockPermissionStatus {
  static const granted = PermissionStatus.granted;
  static const denied = PermissionStatus.denied;
  static const permanentlyDenied = PermissionStatus.permanentlyDenied;
  static const restricted = PermissionStatus.restricted;
  static const limited = PermissionStatus.limited;
  static const provisional = PermissionStatus.provisional;
}