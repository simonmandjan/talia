class AirtelCollectionResponse {
  final bool success;
  final String? message;
  final String? transactionId;
  final String? status;

  AirtelCollectionResponse({
    this.success = false,
    this.message,
    this.transactionId,
    this.status,
  });

  factory AirtelCollectionResponse.fromJson(Map<String, dynamic> json) {
    final statusBlock = json['status'] is Map ? json['status'] as Map<String, dynamic> : <String, dynamic>{};
    final dataBlock = json['data'] is Map ? json['data'] as Map<String, dynamic> : <String, dynamic>{};
    final transactionBlock = dataBlock['transaction'] is Map ? dataBlock['transaction'] as Map<String, dynamic> : <String, dynamic>{};
    return AirtelCollectionResponse(
      success: statusBlock['success'] == true,
      message: statusBlock['message']?.toString(),
      transactionId: transactionBlock['id']?.toString(),
      status: transactionBlock['status']?.toString(),
    );
  }

  bool get isFinalSuccess {
    final s = status?.toUpperCase();
    return s == 'TS' || s == 'SUCCESS';
  }

  bool get isFinalFailure {
    final s = status?.toUpperCase();
    // An explicit failure status is always terminal.
    if (s == 'TF' || s == 'FAILED') return true;
    // success:false with no transaction status at all is the shape of an
    // outright, immediate rejection (bad phone number, validation error),
    // not an ambiguous status poll. Treat that as terminal too.
    if (!success && s == null) return true;
    // Anything else (TIP, unrecognized status, or a malformed/missing
    // status block alongside a real transaction) is ambiguous, not a
    // confirmed failure — the polling loop keeps going, bounded by its own
    // max-attempts timeout, so defaulting to "keep polling" here is safe.
    return false;
  }
}
