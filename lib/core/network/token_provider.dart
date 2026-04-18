abstract interface class TokenProvider {
  Future<String?> getToken();
  Future<String?> refreshToken();
  Future<void> clearToken();
}
