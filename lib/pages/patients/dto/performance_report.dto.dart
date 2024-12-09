//

class PerformanceReport {
  late Map<String, int> evaluations;
  DateTime from;
  DateTime until;

  PerformanceReport.fromJSON(Map<String, dynamic> data)
      : from = DateTime.parse(data['from']),
        until = DateTime.parse(data['until']),
        evaluations = Map<String, int>.from(data['evaluations']);
}
