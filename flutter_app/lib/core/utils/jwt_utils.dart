import 'dart:convert';

/// Decodes a JWT without verifying signature (client-side only).
/// Returns null if the token is malformed.
Map<String, dynamic>? _decodePayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    // JWT uses base64url — pad to a multiple of 4 and swap chars
    String segment = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    switch (segment.length % 4) {
      case 2:
        segment += '==';
      case 3:
        segment += '=';
    }

    final bytes = base64Decode(segment);
    return json.decode(utf8.decode(bytes)) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

/// Returns true when [token] exists, is well-formed, and has not expired.
/// Adds a 10-second buffer to account for minor clock skew.
bool isTokenValid(String? token) {
  if (token == null || token.isEmpty) return false;

  final payload = _decodePayload(token);
  if (payload == null) return false;

  final exp = payload['exp'];
  if (exp == null) return false;

  final expiresAt = DateTime.fromMillisecondsSinceEpoch(
    (exp as int) * 1000,
    isUtc: true,
  );
  return DateTime.now().toUtc().isBefore(expiresAt.subtract(const Duration(seconds: 10)));
}

// isTokenValid(token?)
//   → false if null / empty
//   → false if malformed (not 3 segments)
//   → false if `exp` claim missing
//   → false if now >= exp − 10s
//   → true otherwise
