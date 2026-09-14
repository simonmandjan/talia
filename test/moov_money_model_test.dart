import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_booking/model/MoovMoneyModel.dart';

void main() {
  group('MoovCollectionResponse', () {
    test('parses a successful collection response (TS status)', () {
      final json = {
        "status": {"success": true, "message": "SUCCESS"},
        "data": {
          "transaction": {"id": "MOOV-REF-12345", "status": "TS"},
        },
      };

      final result = MoovCollectionResponse.fromJson(json);

      expect(result.transactionId, "MOOV-REF-12345");
      expect(result.isFinalSuccess, isTrue);
      expect(result.isFinalFailure, isFalse);
    });

    test('parses a failed collection response (TF status)', () {
      final result = MoovCollectionResponse.fromJson({
        "status": {"success": false, "message": "Moov Money rejected the request"},
        "data": {
          "transaction": {"id": "MOOV-REF-12345", "status": "TF"},
        },
      });

      expect(result.isFinalFailure, isTrue);
      expect(result.isFinalSuccess, isFalse);
    });

    test('a transaction still pending (Moov status 100, forwarded raw) is neither success nor failure', () {
      final result = MoovCollectionResponse.fromJson({
        "status": {"success": false, "message": null},
        "data": {
          "transaction": {"id": "MOOV-REF-12345", "status": "100"},
        },
      });

      expect(result.isFinalSuccess, isFalse);
      expect(result.isFinalFailure, isFalse);
    });

    test('an outright rejection (success:false, no transaction) is a final failure', () {
      final result = MoovCollectionResponse.fromJson({
        "status": {"success": false, "message": "Invalid phone number"},
      });

      expect(result.isFinalFailure, isTrue);
      expect(result.message, "Invalid phone number");
    });

    test('a malformed response with no status block at all is not treated as a failure', () {
      // Regression guard: an unexpected/ambiguous shape must not silently
      // stop polling and skip crediting a payment that may have actually
      // succeeded. Keep polling until an explicit TF or an explicit
      // outright success:false rejection is seen. This matters more for
      // Moov than any other gateway in this codebase, since Moov's real
      // field names are unverified (see the design spec's Open Items).
      final result = MoovCollectionResponse.fromJson({
        "data": {
          "transaction": {"id": "MOOV-REF-12345", "status": "TS"},
        },
      });

      expect(result.isFinalFailure, isFalse);
    });

    test('status is treated case-insensitively', () {
      final result = MoovCollectionResponse.fromJson({
        "status": {"success": true},
        "data": {
          "transaction": {"id": "x", "status": "ts"},
        },
      });

      expect(result.isFinalSuccess, isTrue);
    });

    test('backend could not reach Moov keeps polling, not a final failure', () {
      final result = MoovCollectionResponse.fromJson({
        "status": {"success": false, "message": "Unable to reach Moov Money"},
        "data": {
          "transaction": {"id": null, "status": "PENDING"},
        },
      });

      expect(result.isFinalFailure, isFalse);
      expect(result.isFinalSuccess, isFalse);
    });

    test('backend could not parse the Moov response keeps polling, not a final failure', () {
      final result = MoovCollectionResponse.fromJson({
        "status": {"success": false, "message": "Invalid response from Moov Money"},
        "data": {
          "transaction": {"id": null, "status": "PENDING"},
        },
      });

      expect(result.isFinalFailure, isFalse);
      expect(result.isFinalSuccess, isFalse);
    });
  });
}
