import 'package:flutter/material.dart';
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/constants/design.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surgical_counting/src/widgets/instrument_details.dart';

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
    return widget.instrumentsStatus[key]!.passed(defaultInstrumentsData[key]!);
  }

  void showInstrumentDetails(String instrumentId) {
    showDialog(
      context: context,
      builder: (context) {
        return InstrumentDetails(
            settingsController: widget.settingsController,
            instrumentId: instrumentId);
      },
    );
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
              DataTable(
                headingRowColor:
                    MaterialStateProperty.all(dashboardTableHeaderColor),
                showCheckboxColumn: false,
                columnSpacing: 2.0,
                horizontalMargin: 0.0,
                columns: <DataColumn>[
                  const DataColumn(label: Text("")),
                  DataColumn(label: Text(AppLocalizations.of(context)!.object)),
                  DataColumn(label: Text(AppLocalizations.of(context)!.sample)),
                  DataColumn(label: Text(AppLocalizations.of(context)!.order)),
                  DataColumn(
                      label: Text(AppLocalizations.of(context)!.quantity)),
                ],
                rows: defaultInstrumentsData.keys.map<DataRow>((key) {
                  final instrumentStatus = widget.instrumentsStatus[key]!;
                  final isPassed = verifyInstrumentsStatus(key);
                  final orderColor = instrumentStatus.order ==
                          defaultInstrumentsData[key]!['order']
                      ? Colors.green
                      : errorFontColor;
                  final qtyColor = instrumentStatus.qty ==
                          defaultInstrumentsData[key]!['qty']
                      ? Colors.green
                      : errorFontColor;

                  return DataRow(
                    onSelectChanged: (selected) {
                      if (selected!) {
                        showInstrumentDetails(key);
                      }
                    },
                    cells: <DataCell>[
                      DataCell(
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Container(
                            color: isPassed ? Colors.green : errorFontColor,
                            child: Icon(
                              isPassed ? Icons.check : Icons.close,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: Text(defaultInstrumentsData[key]!['name']),
                        ),
                      ),
                      DataCell(
                        Image.network(
                          widget.settingsController.apiUrl +
                              instrumentImageSingleRoute +
                              key,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            defaultInstrumentsData[key]!['image'],
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: Center(
                            child: Text(
                              instrumentStatus.order < 0
                                  ? 'DNE'
                                  : instrumentStatus.order.toString(),
                              style: TextStyle(color: orderColor),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "${instrumentStatus.qty}",
                                style: TextStyle(color: qtyColor),
                              ),
                              Text("/${defaultInstrumentsData[key]!['qty']}"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
