import 'package:flutter/material.dart';
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/constants/design.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetectionInformationPannel extends StatefulWidget {
  const DetectionInformationPannel(
      {super.key,
      required this.settingsController,
      required this.instrumentsStatus});

  final SettingsController settingsController;

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
      backgroundColor: dashboardCardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Table(
                border: const TableBorder(
                  horizontalInside:
                      BorderSide(width: 1.0, color: dashboardTableBorderColor),
                ),
                columnWidths: const <int, TableColumnWidth>{
                  // Passed
                  0: FlexColumnWidth(0.05),
                  // Name
                  1: FlexColumnWidth(0.25),
                  // Image
                  2: FlexColumnWidth(0.45),
                  // Order
                  3: FlexColumnWidth(0.15),
                  // Quantity
                  4: FlexColumnWidth(0.1),
                },

                // Title Row
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      Container(
                        color: dashboardTableHeaderColor,
                        child: const Padding(
                          padding: dashboardTableHeaderPadding,
                          child: Text(""),
                        ),
                      ),

                      // Name
                      Container(
                        color: dashboardTableHeaderColor,
                        child: Padding(
                          padding: dashboardTableHeaderPadding,
                          child: Text(AppLocalizations.of(context)!.object,
                              style: const TextStyle(
                                  color: dashboardTableHeaderTextColor)),
                        ),
                      ),

                      // Image
                      Container(
                        color: dashboardTableHeaderColor,
                        child: Padding(
                          padding: dashboardTableHeaderPadding,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.sample,
                              style: const TextStyle(
                                  color: dashboardTableHeaderTextColor),
                            ),
                          ),
                        ),
                      ),

                      // Order
                      Container(
                        color: dashboardTableHeaderColor,
                        child: Padding(
                          padding: dashboardTableHeaderPadding,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.order,
                              style: const TextStyle(
                                  color: dashboardTableHeaderTextColor),
                            ),
                          ),
                        ),
                      ),

                      // Quantity
                      Container(
                        color: dashboardTableHeaderColor,
                        child: Padding(
                          padding: dashboardTableHeaderPadding,
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.quantity,
                            style: const TextStyle(
                                color: dashboardTableHeaderTextColor),
                          )),
                        ),
                      ),
                    ],
                  ),
                  for (final key in surgicalInstruments.keys)
                    TableRow(
                      children: <Widget>[
                        // Pass
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.fill,
                          child: Container(
                            color: verifyInstrumentsStatus(key)
                                ? Colors.green
                                : Colors.red[900],
                            child: Icon(
                              verifyInstrumentsStatus(key)
                                  ? Icons.check
                                  : Icons.close,
                            ),
                          ),
                        ),

                        // Name
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: Text(surgicalInstruments[key]!['name']),
                        ),

                        // Image
                        Image.network(
                          widget.settingsController.apiUrl +
                              instrumentImageSingleRoute +
                              key,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            surgicalInstruments[key]!['image'],
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                        ),

                        // Order
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: Center(
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
                        ),

                        // Quantity
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
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
      ),
    );
  }
}
