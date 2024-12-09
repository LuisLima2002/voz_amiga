class Patient {
  final String id;
  final String name;

  Patient({required this.id, required this.name});
  Patient.fromJSON(Map<String, dynamic> data)
      : this(
          id: data['id'],
          name: data['name'],
        );
}
