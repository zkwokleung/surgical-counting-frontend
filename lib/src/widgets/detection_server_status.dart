import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surgical_counting/src/constants/design.dart';
import 'package:surgical_counting/src/services/utils.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetectionServerStatus extends StatefulWidget {
  const DetectionServerStatus({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<DetectionServerStatus> createState() => _DetectionServerStatusState();
}

class _DetectionServerStatusState extends State<DetectionServerStatus> {
  bool isServerOn = false;
  bool checkInProgress = false;
  String serverAddress = '';
  String serverPort = '';

  void checkServerStatus() async {
    if (checkInProgress) {
      return;
    }

    setState(() {
      checkInProgress = true;
    });

    try {
      final status = await getServerStatus(widget.settingsController);
      setState(() {
        isServerOn = status;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        isServerOn = false;
      });
    }

    setState(() {
      checkInProgress = false;
    });
  }

  void showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.serverSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serverAddress,
                ),
                onChanged: (value) => serverAddress = value,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serverPort,
                ),
                onChanged: (value) => serverPort = value,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                widget.settingsController.updateApiUrl(
                  serverAddress.contains('http://') ||
                          serverAddress.contains('https://')
                      ? '$serverAddress:$serverPort'
                      : 'http://$serverAddress:$serverPort',
                );
                Navigator.of(context).pop();
                // Show a snackbar to inform the user that the settings have been saved
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.settingsSaved),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    checkServerStatus();
  }

  @override
  Widget build(BuildContext context) {
    return DashCard(
      title: AppLocalizations.of(context)!.serverStatus,
      backgroundColor: dashboardCardBackgroundColor,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: checkServerStatus,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: dashboardSpaceBetweenFloatingButton),
          FloatingActionButton(
            onPressed: showSettings,
            child: const Icon(Icons.settings),
          ),
        ],
      ),
      child: checkInProgress
          ? const CircularProgressIndicator()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('${AppLocalizations.of(context)!.status}: '),
                Icon(
                  isServerOn ? Icons.check_circle : Icons.cancel,
                  color: isServerOn ? Colors.green : Colors.red[900],
                ),
                const Text(' '),
                Text(
                  isServerOn
                      ? AppLocalizations.of(context)!.serverStatusOk
                      : AppLocalizations.of(context)!.serverStatusUnavailable,
                  style: TextStyle(
                      color: isServerOn ? Colors.green : Colors.red[900]),
                ),
              ],
            ),
    );
  }
}
