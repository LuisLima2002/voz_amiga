class AuthResponseDTO {
  final String token;
  final bool resetPassword;
  final bool isPatient;

  AuthResponseDTO.fromJSON(Map<String, dynamic> data)
      : token = data['token'],
        resetPassword = data['updateCredential'] ?? false,
        isPatient = data['isPatient'] ?? true;
}
