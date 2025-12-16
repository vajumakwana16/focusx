import 'package:focusx/utils/utils.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateManager {
  static Future<void> checkForUpdate({bool showMsg = true}) async {
    try {
      // Check if update is available
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (showMsg) Utils.showMSG(msg: 'Update available!');

        // Choose update type based on your requirements
        if (updateInfo.immediateUpdateAllowed) {
          // Immediate update - blocks user until update completes
          await performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Flexible update - allows user to continue using app
          await performFlexibleUpdate();
        }
      } else {
        if (showMsg) Utils.showMSG(msg: 'No update available');
      }
    } catch (e) {
      if (showMsg) Utils.showMSG(msg: 'Error checking for update: $e');
    }
  }

  // Immediate Update - Shows full-screen dialog, blocks user
  static Future<void> performImmediateUpdate() async {
    try {
      AppUpdateResult result = await InAppUpdate.performImmediateUpdate();

      switch (result) {
        case AppUpdateResult.success:
          print('Update completed successfully');
          break;
        case AppUpdateResult.userDeniedUpdate:
          print('User denied the update');
          break;
        case AppUpdateResult.inAppUpdateFailed:
          print('Update failed');
          break;
      }
    } catch (e) {
      print('Error during immediate update: $e');
    }
  }

  // Flexible Update - Downloads in background
  static Future<void> performFlexibleUpdate() async {
    try {
      AppUpdateResult result = await InAppUpdate.startFlexibleUpdate();

      switch (result) {
        case AppUpdateResult.success:
          // Update downloaded, show install prompt
          _showInstallPrompt();
          break;
        case AppUpdateResult.userDeniedUpdate:
          print('User denied the flexible update');
          break;
        case AppUpdateResult.inAppUpdateFailed:
          Utils.showMSG(msg: 'No Update Available!!');
          break;
      }
    } catch (e) {
      Utils.showMSG(msg: 'No Update Available!!');
      print('Error during flexible update: $e');
    }
  }

  static void _showInstallPrompt() {
    // You can show your own dialog or use the built-in one
    InAppUpdate.completeFlexibleUpdate();
  }
}

/*

// Advanced implementation with progress tracking for flexible updates
class AdvancedUpdateManager extends StatefulWidget {
  @override
  _AdvancedUpdateManagerState createState() => _AdvancedUpdateManagerState();
}

class _AdvancedUpdateManagerState extends State<AdvancedUpdateManager> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _setupUpdateListener();
  }

  void _setupUpdateListener() {
    InAppUpdate.flexibleUpdateListener.listen((event) {
      setState(() {
        switch (event.runtimeType) {
          case AppUpdateInstallStatus:
            final status = event as AppUpdateInstallStatus;
            _downloadProgress =
                status.bytesDownloaded / status.totalBytesToDownload;
            _isDownloading = status.installStatus == InstallStatus.downloading;

            if (status.installStatus == InstallStatus.downloaded) {
              // Show install prompt
              _showInstallDialog();
            }
            break;
        }
      });
    });
  }

  void _showInstallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Downloaded'),
        content: Text('Restart the app to apply the update?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              InAppUpdate.completeFlexibleUpdate();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advanced Update Manager')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDownloading) ...[
              Text('Downloading Update...'),
              SizedBox(height: 20),
              LinearProgressIndicator(value: _downloadProgress),
              SizedBox(height: 10),
              Text('${(_downloadProgress * 100).toStringAsFixed(1)}%'),
            ] else ...[
              ElevatedButton(
                onPressed: () => UpdateManager.performFlexibleUpdate(),
                child: Text('Check for Updates'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
*/