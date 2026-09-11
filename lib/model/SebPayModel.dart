class SebPayCountry {
  final String? code;
  final String? name;

  SebPayCountry({this.code, this.name});

  factory SebPayCountry.fromJson(Map<String, dynamic> json) {
    return SebPayCountry(
      code: json['country_code'],
      name: json['country_name'],
    );
  }
}

class SebPayCountriesResponse {
  final List<SebPayCountry> data;

  SebPayCountriesResponse({this.data = const []});

  factory SebPayCountriesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return SebPayCountriesResponse(
      data: list.map((e) => SebPayCountry.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SebPayOperator {
  final String? slug;
  final String? name;
  final bool otpRequired;
  final String? ussdCode;

  SebPayOperator({this.slug, this.name, this.otpRequired = false, this.ussdCode});

  factory SebPayOperator.fromJson(Map<String, dynamic> json) {
    return SebPayOperator(
      slug: json['slug'],
      name: json['name'],
      otpRequired: json['otp_required'] == true,
      ussdCode: json['ussd_code'],
    );
  }
}

class SebPayOperatorsResponse {
  final List<SebPayOperator> data;

  SebPayOperatorsResponse({this.data = const []});

  factory SebPayOperatorsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return SebPayOperatorsResponse(
      data: list.map((e) => SebPayOperator.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SebPayCollectionResponse {
  final bool success;
  final String? message;
  final String? transactionId;
  final String? status;
  final String? providerLink;

  SebPayCollectionResponse({
    this.success = false,
    this.message,
    this.transactionId,
    this.status,
    this.providerLink,
  });

  factory SebPayCollectionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : <String, dynamic>{};
    return SebPayCollectionResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      transactionId: data['transaction_id']?.toString(),
      status: data['status']?.toString(),
      providerLink: data['provider_link']?.toString(),
    );
  }

  bool get isFinalSuccess {
    final s = status?.toLowerCase();
    return success && (s == 'success' || s == 'approved');
  }

  bool get isFinalFailure {
    final s = status?.toLowerCase();
    // An explicit failure status word is always terminal.
    if (s == 'failed' || s == 'rejected') return true;
    // `success == false` with no status field at all is the shape of an
    // outright, immediate collection-creation rejection (e.g. a validation
    // error), not an ambiguous status poll. Treat that as terminal too.
    if (!success && s == null) return true;
    // Anything else (an unrecognized status, or a missing/malformed
    // `success` field alongside some status value) is ambiguous, not a
    // confirmed failure. The polling loop already treats "neither success
    // nor failure" as still-pending and keeps polling, bounded by
    // maxPollAttempts, so defaulting to "keep polling" here is safe.
    return false;
  }
}
