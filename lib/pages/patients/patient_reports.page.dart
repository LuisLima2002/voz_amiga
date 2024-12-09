import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voz_amiga/pages/patients/reports/patient_performance.w.dart';

class PatientReportsPage extends StatefulWidget {
  final String id;

  const PatientReportsPage({super.key, required this.id});

  @override
  State<PatientReportsPage> createState() => _PatientReportsPageState();
}

class _PatientReportsPageState extends State<PatientReportsPage> {
  int _reportType = 1;
  final _dateFormater = DateFormat('dd/MM/yyyy');
  late TextEditingController _fromController;
  late TextEditingController _untilController;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(
      text: _dateFormater.format(
        DateTime.now(),
      ),
    );
    _untilController = TextEditingController(
      text: _dateFormater.format(
        DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var width = constraints.maxWidth;
      return Column(
        children: [
          _form(width),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 20,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: math.min(width, 1024),
                    height: math.min(width, 1024) * 0.5625, //16:9
                    child: PatientPerformance(
                      patientId: widget.id,
                      from: _dateFormater.parse(_fromController.text),
                      until: _dateFormater.parse(_untilController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget get _type {
    return DropdownButtonFormField<int>(
      autofocus: false,
      value: _reportType,
      items: const [
        DropdownMenuItem(
          value: 1,
          child: Text("Desempenho"),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text("Frequência"),
        ),
        DropdownMenuItem(
          value: 3,
          child: Text("Progresso"),
        ),
      ],
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 5),
        hintText: "",
        labelText: "Tipo de relatório",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
      onChanged: (int? value) {
        setState(() {
          _reportType = value ?? 1;
        });
      },
    );
  }

  Widget _form(double width) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        child: Column(
          children: [
            SizedBox(
              width: math.min(width, 1024),
              child: Flex(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 3,
                    fit: FlexFit.loose,
                    child: _type,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: TextFormField(
                      controller: _fromController,
                      readOnly: true,
                      onTap: () {
                        showDatePicker(
                          context: context,
                          firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                          lastDate: DateTime.now(),
                        ).then((date) {
                          if (date != null) {
                            final isFromAfterUntil = date.compareTo(
                                  _dateFormater.parse(_untilController.text),
                                ) >
                                0;
                            if (isFromAfterUntil) {
                              _untilController.text =
                                  _dateFormater.format(date);
                            }
                            _fromController.text = _dateFormater.format(date);
                          }
                        }).catchError((_) {});
                      },
                      decoration: const InputDecoration(
                        label: Text('De:'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: TextFormField(
                      controller: _untilController,
                      readOnly: true,
                      onTap: () {
                        showDatePicker(
                          context: context,
                          firstDate: _dateFormater.parse(_fromController.text),
                          lastDate: DateTime.now(),
                        ).then((date) {
                          if (date != null) {
                            _untilController.text = _dateFormater.format(date);
                          }
                        }).catchError((_) {});
                      },
                      decoration: const InputDecoration(
                        label: Text('Até:'),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
