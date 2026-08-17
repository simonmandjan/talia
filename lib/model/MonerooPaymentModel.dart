class MonerooInitResponse {
  final String? id;
  final String? checkoutUrl;

  MonerooInitResponse({this.id, this.checkoutUrl});

  factory MonerooInitResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return MonerooInitResponse(
      id: data['id'],
      checkoutUrl: data['checkout_url'],
    );
  }
}

class MonerooVerifyResponse {
  final String? id;
  final String? status;

  MonerooVerifyResponse({this.id, this.status});

  factory MonerooVerifyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return MonerooVerifyResponse(
      id: data['id'],
      status: data['status'],
    );
  }

  bool get isSuccess => status == 'success';
}
