import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // static Future<bool> getStoragePermission() async {
  //   if (await Permission.storage.isGranted) return true;
  //   return (await Permission.storage.request().isGranted) ? true : false;
  // }

  // static Future<bool> getCameraPermission() async {
  //   if (await Permission.camera.isGranted) return true;
  //   return (await Permission.camera.request().isGranted) ? true : false;
  // }
  static Future<bool> getPicturePermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage, Permission.camera].request();

    return statuses[Permission.storage].isGranted &&
        statuses[Permission.camera].isGranted;
  }
}
