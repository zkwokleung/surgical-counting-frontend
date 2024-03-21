import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetectionInformationPannel extends StatefulWidget {
  const DetectionInformationPannel(
      {super.key, required this.instrumentsStatus});

  final Map<String, dynamic> instrumentsStatus;

  @override
  State<DetectionInformationPannel> createState() =>
      _DetectionInformationPannelState();
}

class _DetectionInformationPannelState
    extends State<DetectionInformationPannel> {
  bool verifyInstrumentsStatus(String key) {
    return widget.instrumentsStatus[key]!.passed(surgicalInstruments[key]!);
  }

  @override
  Widget build(BuildContext context) {
    return DashCard(
      title: AppLocalizations.of(context)!.information,
      backgroundColor: Colors.grey[600],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                // Passed
                0: FlexColumnWidth(0.03),
                // Name
                1: FlexColumnWidth(0.2),
                // Order
                2: FlexColumnWidth(0.7),
                // Quantity
                3: FlexColumnWidth(0.1),
              },

              // Title Row
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Container(),

                    // Name
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 2.0, 2.0),
                      child: Text(AppLocalizations.of(context)!.object),
                    ),

                    // Order
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 2.0, 2.0),
                      child: Text(AppLocalizations.of(context)!.order),
                    ),

                    // Quantity
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                      child: Center(
                          child: Text(AppLocalizations.of(context)!.quantity)),
                    ),
                  ],
                ),
                for (final key in surgicalInstruments.keys)
                  TableRow(
                    children: <Widget>[
                      // Pass
                      Container(
                        color: verifyInstrumentsStatus(key)
                            ? Colors.green
                            : Colors.red[900],
                        child: Center(
                          child: Icon(
                            verifyInstrumentsStatus(key)
                                ? Icons.check
                                : Icons.close,
                          ),
                        ),
                      ),

                      // Name
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                        child: Text(surgicalInstruments[key]!['name']),
                      ),

                      // Order
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                        child: Text(
                          style: TextStyle(
                            color: widget.instrumentsStatus[key]!.order ==
                                    surgicalInstruments[key]!['order']
                                ? Colors.green
                                : Colors.red[900],
                          ),
                          widget.instrumentsStatus[key]!.qty > 1
                              ? 'MUL'
                              : (widget.instrumentsStatus[key]!.order < 0
                                  ? 'DNE'
                                  : widget.instrumentsStatus[key]!.order
                                      .toString()),
                        ),
                      ),

                      // Quantity
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                style: TextStyle(
                                  color: widget.instrumentsStatus[key]!.qty ==
                                          surgicalInstruments[key]!['qty']
                                      ? Colors.green
                                      : Colors.red[900],
                                ),
                                "${widget.instrumentsStatus[key]!.qty}"),
                            Text("/${surgicalInstruments[key]!['qty']}"),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
