import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:voz_amiga/pages/patients/dto/performance_report.dto.dart';
import 'package:voz_amiga/pages/patients/services/report.service.dart';

class PatientPerformance extends StatefulWidget {
  final String patientId;
  final DateTime from;
  final DateTime? until;
  const PatientPerformance({
    super.key,
    required this.patientId,
    required this.from,
    this.until,
  });

  @override
  State<PatientPerformance> createState() => _PatientPerformanceState();
}

class _PatientPerformanceState extends State<PatientPerformance> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPerformanceData(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.data?.$1 != null) {
          } else {
            return _chart(snap.data!.$2!);
          }
        } else if (true) {}
        return const Center(
          child: Text('erro'),
        );
      },
    );
  }

  Future<(String? error, PerformanceReport? data)> _getPerformanceData() async {
    final res = await ReportService.performance(
      patientId: widget.patientId,
      from: widget.from,
    );
    return res;
  }

  Widget _chart(PerformanceReport performanceReport) {
    return Chart(
      data: const [
        {'genre': 'Sports', 'sold': 275},
        {'genre': 'Strategy', 'sold': 115},
        {'genre': 'Action', 'sold': 120},
        {'genre': 'Shooter', 'sold': 350},
        {'genre': 'Other', 'sold': 150},
      ],
      variables: {
        'genre': Variable(
          accessor: (Map map) => map['genre'] as String,
        ),
        'sold': Variable(
          accessor: (Map map) => map['sold'] as num,
        ),
      },
      marks: [IntervalMark()],
      axes: [
        Defaults.horizontalAxis,
        Defaults.verticalAxis,
      ],
    );
  }
}
