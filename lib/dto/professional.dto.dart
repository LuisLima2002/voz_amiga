
class ProfessionalDTO {
  final String id;
  final String name;
  final String email;


  const ProfessionalDTO({
    required this.id,
    required this.name,
    required this.email,
  });

  ProfessionalDTO.fromJSON(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        email = data['email']
      ;

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
