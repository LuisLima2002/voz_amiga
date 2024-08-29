import 'package:intl/intl.dart';

class PatientDTO {
  final String id;
  final String name;
  final String birthdate;
  final String emergencyContact;
  final String cpfPatient;
  final String nameResponsible;
  final String responsibleDocument;
  final String code;


  const PatientDTO({
    required this.id,
    required this.name,
    required this.birthdate,
    required this.emergencyContact,
    required this.cpfPatient,
    required this.nameResponsible,
    required this.responsibleDocument,
    required this.code,
  });

  PatientDTO.fromJSON(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        birthdate = data['birthdate'],
        emergencyContact = data['emergencyContact'],
        cpfPatient = data['cpfPatient'],
        nameResponsible = data['nameResponsible'],
        responsibleDocument = data['responsibleDocument'],
        code = data['code']
      ;

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthdate': DateFormat('dd/MM/yyyy').parse(birthdate).toIso8601String(),
      'emergencyContact': emergencyContact,
      'cpfPatient': cpfPatient,
      'nameResponsible': nameResponsible,
      'responsibleDocument': responsibleDocument,
      'code': code
    };
  }
}
