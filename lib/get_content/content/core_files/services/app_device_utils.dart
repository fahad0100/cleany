String appDeviceUtilsFile() {
  return '''
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

abstract class AppDeviceUtils {
  static String appName = '';
  static String packageName = '';
  static String version = '';
  static String buildNumber = '';

  static String deviceName = '';
  static String deviceId = '';
  static String osVersion = '';
  static String deviceModel = '';
  static String deviceManufacturer = '';
  static String store = '';
  static String? update;

  static Future<void> init() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      store = packageInfo.installerStore ?? "Unknown store";
      update = packageInfo.updateTime?.toIso8601String() ?? "Unknown update";
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        deviceName = webInfo.userAgent ?? 'Web Browser';
        deviceModel = 'Web';
        osVersion = 'Web';
        deviceId = webInfo.vendor ?? 'Unknown Web Vendor';
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.device;
        deviceManufacturer = androidInfo.manufacturer;
        deviceModel = androidInfo.model;
        osVersion =
            'Android \${androidInfo.version.release} (SDK \${androidInfo.version.sdkInt})';
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        deviceManufacturer = 'Apple';
        osVersion = '\${iosInfo.systemName} \${iosInfo.systemVersion}';
        deviceId = iosInfo.identifierForVendor ?? 'Unknown ID';
      }
    } catch (e) {
      debugPrint('Error initializing AppDeviceUtils: \$e');
    }
  }

  static Future<Map<String, dynamic>> getAllDetails() async {
    await init();
    return {
      'app_name': appName,
      'package_name': packageName,
      'version': version,
      'build_number': buildNumber,
      'device_name': deviceName,
      'manufacturer': deviceManufacturer,
      'model': deviceModel,
      'os_version': osVersion,
      'device_id': deviceId,
      'store': store,
      'update': update,
    };
  }
}
''';
}
