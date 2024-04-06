import 'package:flutter/material.dart';
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InstrumentDetails extends StatefulWidget {
  const InstrumentDetails({
    super.key,
    required this.settingsController,
    required this.instrumentId,
  });

  final SettingsController settingsController;

  final String instrumentId;

  @override
  State<InstrumentDetails> createState() => _InstrumentDetailsState();
}

class _InstrumentDetailsState extends State<InstrumentDetails> {
  @override
  Widget build(BuildContext context) {
    // Create a dialog to display the instrument details
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.instrumentDetails),
      insetPadding: const EdgeInsets.all(0.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image
          Image.network(
            widget.settingsController.apiUrl +
                instrumentImageSingleRoute +
                widget.instrumentId,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              defaultInstrumentsData[widget.instrumentId]!['image'],
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
          ),

          Text(
            "${AppLocalizations.of(context)!.instrumentId}: ${widget.instrumentId}",
          ),

          // Display the instrument name
          Text(
            "${AppLocalizations.of(context)!.instrumentName}: " +
                widget.settingsController
                    .instruments[widget.instrumentId]!['name'],
          ),

          // Display the instrument description
          Text(
            widget.settingsController
                .instruments[widget.instrumentId]!['description'],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}
