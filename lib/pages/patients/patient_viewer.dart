import 'package:flutter/material.dart';

class PatientViewerPage extends StatelessWidget {
  final String id;
  const PatientViewerPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text(id)],
    );
  }
}
