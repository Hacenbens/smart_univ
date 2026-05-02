abstract interface class TokenProvider {
  String? getToken();
  Future<String?> refreshToken();
  Future<void> clearToken();
}
