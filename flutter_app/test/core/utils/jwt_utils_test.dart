import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:not3s/core/utils/jwt_utils.dart';

/// Builds a minimal fake JWT token with the given payload.
/// Uses dummy header/signature strings since only the payload is decoded.
String _makeToken(Map<String, dynamic> payload) {
  final encoded = base64Url
      .encode(utf8.encode(json.encode(payload)))
      .replaceAll('=', ''); // JWT uses unpadded base64url
  return 'eyJhbGciOiJIUzI1NiJ9.$encoded.fake_signature';
}

int _exp(Duration fromNow) =>
    DateTime.now().toUtc().add(fromNow).millisecondsSinceEpoch ~/ 1000;

void main() {
  group('isTokenValid', () {
    // ── Null / empty ──────────────────────────────────────────────────────────

    test('returns false for null', () {
      expect(isTokenValid(null), isFalse);
    });

    test('returns false for empty string', () {
      expect(isTokenValid(''), isFalse);
    });

    // ── Malformed structure ───────────────────────────────────────────────────

    test('returns false when token has only 2 parts', () {
      expect(isTokenValid('header.payload'), isFalse);
    });

    test('returns false when token has 4 parts', () {
      expect(isTokenValid('a.b.c.d'), isFalse);
    });

    test('returns false when token has 1 part', () {
      expect(isTokenValid('singlepart'), isFalse);
    });

    test('returns false for invalid base64 in payload segment', () {
      expect(isTokenValid('header.!!!not_valid_base64!!!.signature'), isFalse);
    });

    test('returns false when payload is not valid JSON', () {
      final invalidJson = base64Url.encode(utf8.encode('not_json'));
      expect(isTokenValid('h.$invalidJson.s'), isFalse);
    });

    // ── Missing exp claim ─────────────────────────────────────────────────────

    test('returns false when exp claim is absent', () {
      final token = _makeToken({'userId': 42, 'username': 'alice'});
      expect(isTokenValid(token), isFalse);
    });

    test('returns false when exp is null in payload', () {
      final token = _makeToken({'exp': null});
      expect(isTokenValid(token), isFalse);
    });

    // ── Expired tokens ────────────────────────────────────────────────────────

    test('returns false for token that expired 1 hour ago', () {
      final token = _makeToken({'exp': _exp(const Duration(hours: -1))});
      expect(isTokenValid(token), isFalse);
    });

    test('returns false for token that expired 1 second ago', () {
      final token = _makeToken({'exp': _exp(const Duration(seconds: -1))});
      expect(isTokenValid(token), isFalse);
    });

    // ── 10-second skew buffer ─────────────────────────────────────────────────

    test('returns false for token expiring in 5 seconds (within 10 s buffer)', () {
      final token = _makeToken({'exp': _exp(const Duration(seconds: 5))});
      expect(isTokenValid(token), isFalse);
    });

    test('returns false for token expiring in exactly 10 seconds (boundary)', () {
      final token = _makeToken({'exp': _exp(const Duration(seconds: 10))});
      // now >= exp - 10s, so should be false (edge of buffer)
      expect(isTokenValid(token), isFalse);
    });

    // ── Valid tokens ──────────────────────────────────────────────────────────

    test('returns true for token expiring in 1 hour', () {
      final token = _makeToken({'exp': _exp(const Duration(hours: 1))});
      expect(isTokenValid(token), isTrue);
    });

    test('returns true for token expiring in 24 hours', () {
      final token = _makeToken({'exp': _exp(const Duration(hours: 24))});
      expect(isTokenValid(token), isTrue);
    });

    test('returns true for token with extra claims alongside exp', () {
      final token = _makeToken({
        'exp': _exp(const Duration(hours: 2)),
        'userId': 99,
        'username': 'bob',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      expect(isTokenValid(token), isTrue);
    });

    // ── Edge case: exp = 0 (Unix epoch) ──────────────────────────────────────

    test('returns false for token with exp = 0 (Unix epoch)', () {
      final token = _makeToken({'exp': 0});
      expect(isTokenValid(token), isFalse);
    });
  });
}
