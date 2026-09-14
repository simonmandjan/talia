import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_booking/model/AirtelMoneyModel.dart';

void main() {
  group('AirtelCollectionResponse', () {
    test('parses a successful collection response (TS status)', () {
      final json = {
        "status": {"success": true, "message": "SUCCESS"},
        "data": {
          "transaction": {"id": "MP240101.1234.A12345", "status": "TS"},
        },
      };

      final result = AirtelCollectionResponse.fromJson(json);

      expect(result.transactionId, "MP240101.1234.A12345");
      expect(result.isFinalSuccess, isTrue);
      expect(result.isFinalFailure, isFalse);
    });

    test('parses a failed collection response (TF status)', () {
      final result = AirtelCollectionResponse.fromJson({
        "status": {"success": true, "message": "SUCCESS"},
        "data": {
          "transaction": {"id": "MP240101.1234.A12345", "status": "TF"},
        },
      });

      expect(result.isFinalFailure, isTrue);
      expect(result.isFinalSuccess, isFalse);
    });

    test('a transaction still in progress (TIP) is neither success nor failure', () {
      final result = AirtelCollectionResponse.fromJson({
        "status": {"success": true, "message": "SUCCESS"},
        "data": {
          "transaction": {"id": "MP240101.1234.A12345", "status": "TIP"},
        },
      });

      expect(result.isFinalSuccess, isFalse);
      expect(result.isFinalFailure, isFalse);
    });

    test('an outright rejection (success:false, no transaction) is a final failure', () {
      final result = AirtelCollectionResponse.fromJson({
        "status": {"success": false, "message": "Invalid phone number"},
      });

      expect(result.isFinalFailure, isTrue);
      expect(result.message, "Invalid phone number");
    });

    test('a malformed response with no status block at all is not treated as a failure', () {
      // Regression guard: an unexpected/ambiguous shape must not silently
      // stop polling and skip crediting a payment that may have actually
      // succeeded. Keep polling until an explicit TF/FAILED or an explicit
      // outright success:false rejection is seen.
      final result = AirtelCollectionResponse.fromJson({
        "data": {
          "transaction": {"id": "MP240101.1234.A12345", "status": "TS"},
        },
      });

      expect(result.isFinalFailure, isFalse);
    });

    test('status is treated case-insensitively', () {
      final result = AirtelCollectionResponse.fromJson({
        "status": {"success": true},
        "data": {
          "transaction": {"id": "x", "status": "ts"},
        },
      });

      expect(result.isFinalSuccess, isTrue);
    });
  });
}
