import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as DTL;
import 'package:intl/intl.dart';
import 'package:voz_amiga/dto/frequencyReport.dto.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';
import 'dart:async';

class PatientFrequencyReportPage extends StatefulWidget {
  final String id;

  const PatientFrequencyReportPage({super.key, required this.id});

  @override
  State<PatientFrequencyReportPage> createState() =>
      _PatientFrequencyReportPageState();
}

class _PatientFrequencyReportPageState
    extends State<PatientFrequencyReportPage> {
  Future<(dynamic, FrequencyReportDTO?)>? _frFuture;

  @override
  void initState() {
    super.initState();
    _monthYearController.text = DateFormat('MM/yyyy').format(DateTime.now());
    _frFuture = PatientsService.getFrequencyReport(widget.id, DateTime.now());
  }

  final TextEditingController _monthYearController = TextEditingController();

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? pickedDate = await DTL.DatePicker.showPicker(context,
        pickerModel: CustomMonthPicker(
            minTime: DateTime(2020, 1, 1),
            maxTime: DateTime.now(),
            currentTime: DateTime.now()));

    @override
    void dispose() {
      _monthYearController.dispose();
      super.dispose();
    }

    if (pickedDate != null) {
      // Format and set the month/year in the controller
      final String formattedDate = DateFormat('MM/yyyy').format(pickedDate);
      _monthYearController.text = formattedDate;
      setState(() {
        _frFuture = PatientsService.getFrequencyReport(widget.id, pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<(dynamic, FrequencyReportDTO?)>(
        future: _frFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final (error, fr) = snapshot.data!;
            if (fr == null) {
              return Center(child: Text('Error: $error'));
            }
            return Card(
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _monthYearController,
                      readOnly: true, // Make the field non-editable
                      decoration: const InputDecoration(
                        labelText: "Selecione a data do relatório",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectMonthYear(context),
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: fr.assignedActivitiesFrequency.isNotEmpty
                          ? DataTable(
                              columns: const [
                                DataColumn(label: Text("Nome")),
                                DataColumn(label: Text("Tentativas")),
                                DataColumn(label: Text("Status")),
                              ],
                              rows: fr.assignedActivitiesFrequency
                                  .map(
                                    (data) => DataRow(cells: [
                                      DataCell(Text(
                                        data.assignedExercise.exercise!.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      DataCell(data.expectedAttempts <=
                                              data.doneAttempts
                                          ? Text(
                                              "${data.expectedAttempts} esperado")
                                          : Text(
                                              "${data.doneAttempts} de ${data.expectedAttempts}")),
                                      DataCell(
                                        Icon(
                                          Icons.check_circle,
                                          size: 20,
                                          color: data.expectedAttempts <=
                                                  data.doneAttempts
                                              ? Colors.green
                                              : (data.doneAttempts > 0
                                                  ? Colors.yellow
                                                  : Colors.red),
                                        ),
                                      ),
                                    ]),
                                  )
                                  .toList(),
                            )
                          : const Center(
                              child: Text("Sem dados nesse mes"),
                            ),
                      // ListView.builder(
                      //     itemCount: fr.assignedActivitiesFrequency.length,
                      //     itemBuilder: (_, index) {
                      //       return Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Text(
                      //             fr.assignedActivitiesFrequency[index]
                      //                 .assignedExercise.exercise!.title,
                      //             style: Theme.of(context).textTheme.titleLarge,
                      //           ),
                      //           Row(
                      //             children: [
                      //               Icon(
                      //                 Icons.check_circle,
                      //                 size: 20,
                      //                 color: fr
                      //                             .assignedActivitiesFrequency[
                      //                                 index]
                      //                             .expectedAttempts <=
                      //                         fr
                      //                             .assignedActivitiesFrequency[
                      //                                 index]
                      //                             .doneAttempts
                      //                     ? Colors.green
                      //                     : (fr.assignedActivitiesFrequency[index]
                      //                                 .doneAttempts >
                      //                             0
                      //                         ? Colors.yellow
                      //                         : Colors.red),
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       );
                      //       // return Card(
                      //       //   margin:
                      //       //       const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      //       //   color: Colors.deepPurpleAccent,
                      //       //   child: ListTile(
                      //       //     onTap: () {},
                      //       //     title: Text(
                      //       //       fr.assignedActivitiesFrequency[index].assignedExercise
                      //       //           .exercise!.title,
                      //       //       style: const TextStyle(
                      //       //           fontWeight: FontWeight.bold,
                      //       //           fontSize: 18,
                      //       //           color: Colors.white),
                      //       //     ),
                      //       //   ),
                      //       // );
                      //     }),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class DayReport {
  final String date; // e.g., "Mon, Nov 27"
  final bool isTaskAssigned;
  final bool isAttemptMade;

  DayReport({
    required this.date,
    required this.isTaskAssigned,
    required this.isAttemptMade,
  });
}

class CustomMonthPicker extends DTL.DatePickerModel {
  CustomMonthPicker(
      {required DateTime currentTime,
      required DateTime minTime,
      required DateTime maxTime})
      : super(minTime: minTime, maxTime: maxTime, currentTime: currentTime);

  @override
  List<int> layoutProportions() {
    return [1, 1, 0];
  }
}
