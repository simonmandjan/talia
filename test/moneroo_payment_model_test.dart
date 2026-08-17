import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_booking/model/MonerooPaymentModel.dart';

void main() {
  group('MonerooInitResponse', () {
    test('parses id and checkout_url from a successful initialize response', () {
      final json = {
        "message": "Transaction initialized successfully",
        "data": {
          "id": "5f7b1b2c",
          "checkout_url": "https://checkout.moneroo.io/5f7b1b2c",
        },
      };

      final result = MonerooInitResponse.fromJson(json);

      expect(result.id, "5f7b1b2c");
      expect(result.checkoutUrl, "https://checkout.moneroo.io/5f7b1b2c");
    });

    test('leaves fields null when data is missing', () {
      final result = MonerooInitResponse.fromJson({"message": "error"});

      expect(result.id, isNull);
      expect(result.checkoutUrl, isNull);
    });
  });

  group('MonerooVerifyResponse', () {
    test('isSuccess is true only when status is "success"', () {
      final success = MonerooVerifyResponse.fromJson({
        "data": {"id": "k4su1ii7abdz", "status": "success"},
      });
      final pending = MonerooVerifyResponse.fromJson({
        "data": {"id": "k4su1ii7abdz", "status": "pending"},
      });
      final failed = MonerooVerifyResponse.fromJson({
        "data": {"id": "k4su1ii7abdz", "status": "failed"},
      });

      expect(success.isSuccess, isTrue);
      expect(pending.isSuccess, isFalse);
      expect(failed.isSuccess, isFalse);
    });
  });
}
