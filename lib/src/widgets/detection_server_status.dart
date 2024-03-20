import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surgical_counting/src/services/utils.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetectionServerStatus extends StatefulWidget {
  const DetectionServerStatus({super.key});

  @override
  State<DetectionServerStatus> createState() => _DetectionServerStatusState();
}

class _DetectionServerStatusState extends State<DetectionServerStatus> {
  bool isServerOn = false;

  void checkServerStatus() async {
    try {
      final status = await getServerStatus();
      setState(() {
        isServerOn = status;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
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
      backgroundColor: Colors.grey[600],
      floatingActionButton: FloatingActionButton(
        onPressed: checkServerStatus,
        child: const Icon(Icons.refresh),
      ),
      child: Row(
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
            style:
                TextStyle(color: isServerOn ? Colors.green : Colors.red[900]),
          ),
        ],
      ),
    );
  }
}
