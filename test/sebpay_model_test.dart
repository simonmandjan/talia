import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_booking/model/SebPayModel.dart';

void main() {
  group('SebPayCountriesResponse', () {
    test('parses a list of countries', () {
      final json = {
        "success": true,
        "data": [
          {"country_code": "BJ", "country_name": "Bénin"},
          {"country_code": "CI", "country_name": "Côte d'Ivoire"},
        ],
      };

      final result = SebPayCountriesResponse.fromJson(json);

      expect(result.data.length, 2);
      expect(result.data.first.code, "BJ");
      expect(result.data.first.name, "Bénin");
    });

    test('returns an empty list when data is missing', () {
      final result = SebPayCountriesResponse.fromJson({"success": false});
      expect(result.data, isEmpty);
    });
  });

  group('SebPayOperatorsResponse', () {
    test('parses operators including otp_required and ussd_code', () {
      final json = {
        "success": true,
        "data": [
          {"slug": "mtn", "name": "MTN Mobile Money", "otp_required": false, "ussd_code": "*880#"},
          {"slug": "orange", "name": "Orange Money", "otp_required": true, "ussd_code": "*144#"},
        ],
      };

      final result = SebPayOperatorsResponse.fromJson(json);

      expect(result.data.length, 2);
      expect(result.data[0].otpRequired, isFalse);
      expect(result.data[1].slug, "orange");
      expect(result.data[1].otpRequired, isTrue);
      expect(result.data[1].ussdCode, "*144#");
    });

    test('treats a missing otp_required as false', () {
      final result = SebPayOperatorsResponse.fromJson({
        "data": [
          {"slug": "wav", "name": "Wave"},
        ],
      });
      expect(result.data.first.otpRequired, isFalse);
    });
  });

  group('SebPayCollectionResponse', () {
    test('a freshly created collection is pending, not success or failure', () {
      final result = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {"transaction_id": "TXN123", "status": "pending"},
      });

      expect(result.transactionId, "TXN123");
      expect(result.isFinalSuccess, isFalse);
      expect(result.isFinalFailure, isFalse);
    });

    test('isFinalSuccess is true for both documented success spellings', () {
      final approved = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {"transaction_id": "TXN123", "status": "approved"},
      });
      final success = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {"transaction_id": "TXN123", "status": "SUCCESS"},
      });

      expect(approved.isFinalSuccess, isTrue);
      expect(success.isFinalSuccess, isTrue);
    });

    test('isFinalFailure is true for both documented failure spellings', () {
      final rejected = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {"transaction_id": "TXN123", "status": "rejected"},
      });
      final failed = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {"transaction_id": "TXN123", "status": "FAILED"},
      });

      expect(rejected.isFinalFailure, isTrue);
      expect(failed.isFinalFailure, isTrue);
    });

    test('isFinalFailure is true when the API rejects the request outright', () {
      final result = SebPayCollectionResponse.fromJson({
        "success": false,
        "message": "otp_code is required for this operator",
      });

      expect(result.isFinalFailure, isTrue);
      expect(result.message, "otp_code is required for this operator");
    });

    test('captures a Wave provider_link when present', () {
      final result = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {
          "transaction_id": "TXN123",
          "status": "pending",
          "provider_link": "https://pay.wave.com/checkout/abc",
        },
      });

      expect(result.providerLink, "https://pay.wave.com/checkout/abc");
    });

    test('a recognized status with no top-level success key at all is not treated as a final failure', () {
      // Regression test: an ambiguous/ untested response shape (missing the
      // `success` key entirely) must not be treated as a confirmed terminal
      // failure just because a recognized status is present. Polling should
      // keep going rather than stop and skip crediting the wallet.
      final result = SebPayCollectionResponse.fromJson({
        "data": {"transaction_id": "TXN123", "status": "approved"},
      });

      expect(result.isFinalFailure, isFalse);
    });

    test('transaction_id given as an integer parses to a string without throwing', () {
      final result = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {"transaction_id": 12345, "status": "pending"},
      });

      expect(result.transactionId, "12345");
    });

    test('data present as a JSON array instead of an object does not throw', () {
      final result = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": ["unexpected", "array"],
      });

      expect(result.transactionId, isNull);
      expect(result.status, isNull);
      expect(result.providerLink, isNull);
    });

    test('an unrecognized status string is neither a final success nor a final failure', () {
      final result = SebPayCollectionResponse.fromJson({
        "success": true,
        "data": {"transaction_id": "TXN123", "status": "cancelled"},
      });

      expect(result.isFinalSuccess, isFalse);
      expect(result.isFinalFailure, isFalse);
    });
  });
}
