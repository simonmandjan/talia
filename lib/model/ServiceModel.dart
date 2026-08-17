import '../manage_imports.dart';

class ServiceModel {
  List<ServiceList>? data;
  PaginationModel? pagination;

  ServiceModel({this.data, this.pagination});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => ServiceList.fromJson(i)).toList()
          : null,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class ServiceList {
  num? adminCommission;
  num? baseFare;
  num? cancellationFee;
  num? capacity;
  String? commissionType;
  String? createdAt;
  num? fleetCommission;
  num? id;
  var minimumDistance;
  num? minimumFare;
  String? name;
  String? paymentMethod;
  num? perDistance;
  num? perDistancePriorCancel;
  num? perMinuteDrive;
  num? perMinutePriorCancel;
  num? perMinuteWait;
  Region? region;
  num? regionId;
  String? serviceImage;
  num? status;
  String? updatedAt;
  num? waitingTimeLimit;

  ServiceList({
    this.adminCommission,
    this.baseFare,
    this.cancellationFee,
    this.capacity,
    this.commissionType,
    this.createdAt,
    this.fleetCommission,
    this.id,
    this.minimumDistance,
    this.minimumFare,
    this.name,
    this.paymentMethod,
    this.perDistance,
    this.perDistancePriorCancel,
    this.perMinuteDrive,
    this.perMinutePriorCancel,
    this.perMinuteWait,
    this.region,
    this.regionId,
    this.serviceImage,
    this.status,
    this.updatedAt,
    this.waitingTimeLimit,
  });

  factory ServiceList.fromJson(Map<String, dynamic> json) {
    return ServiceList(
      adminCommission: num.tryParse(json['admin_commission'].toString()),
      baseFare: num.tryParse(json['base_fare'].toString()),
      cancellationFee: num.tryParse(json['cancellation_fee'].toString()),
      // 😉 Sécurisé en int pour la capacité (nombre de places)
      capacity: num.tryParse(json['capacity'].toString())?.toInt(),
      commissionType: json['commission_type'],
      createdAt: json['created_at'],
      fleetCommission: num.tryParse(json['fleet_commission'].toString()),
      // 😉 Sécurisé en int pour l'ID du service
      id: num.tryParse(json['id'].toString())?.toInt(),
      minimumDistance: num.tryParse(json['minimum_distance'].toString()),
      minimumFare: num.tryParse(json['minimum_fare'].toString()),
      name: json['name'],
      paymentMethod: json['payment_method'],
      perDistance: num.tryParse(json['per_distance'].toString()),
      perDistancePriorCancel: num.tryParse(json['per_distance_prior_cancel'].toString()),
      perMinuteDrive: num.tryParse(json['per_minute_drive'].toString()),
      perMinutePriorCancel: num.tryParse(json['per_minute_prior_cancel'].toString()),
      perMinuteWait: num.tryParse(json['per_minute_wait'].toString()),
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
      // 😉 Sécurisé en int pour l'ID de la région
      regionId: num.tryParse(json['region_id'].toString())?.toInt(),
      serviceImage: json['service_image'],
      // 🛠️ FIX CRITIQUE : Le statut doit être un int (0 ou 1) et non un num
      status: num.tryParse(json['status'].toString())?.toInt(),
      updatedAt: json['updated_at'],
      waitingTimeLimit: num.tryParse(json['waiting_time_limit'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin_commission'] = this.adminCommission;
    data['base_fare'] = this.baseFare;
    data['cancellation_fee'] = this.cancellationFee;
    data['capacity'] = this.capacity;
    data['commission_type'] = this.commissionType;
    data['created_at'] = this.createdAt;
    data['fleet_commission'] = this.fleetCommission;
    data['id'] = this.id;
    data['minimum_distance'] = this.minimumDistance;
    data['minimum_fare'] = this.minimumFare;
    data['name'] = this.name;
    data['payment_method'] = this.paymentMethod;
    data['per_distance'] = this.perDistance;
    data['per_distance_prior_cancel'] = this.perDistancePriorCancel;
    data['per_minute_drive'] = this.perMinuteDrive;
    data['per_minute_prior_cancel'] = this.perMinutePriorCancel;
    data['per_minute_wait'] = this.perMinuteWait;
    data['region_id'] = this.regionId;
    data['service_image'] = this.serviceImage;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['waiting_time_limit'] = this.waitingTimeLimit;
    if (this.region != null) {
      data['region'] = this.region!.toJson();
    }
    return data;
  }
}

class Region {
  String? createdAt;
  String? currencyCode;
  String? currencyName;
  String? distanceUnit;
  int? id;
  String? name;
  int? status;
  String? timezone;
  String? updatedAt;

  Region(
      {this.createdAt,
      this.currencyCode,
      this.currencyName,
      this.distanceUnit,
      this.id,
      this.name,
      this.status,
      this.timezone,
      this.updatedAt});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      createdAt: json['created_at'],
      currencyCode: json['currency_code'],
      currencyName: json['currency_name'],
      distanceUnit: json['distance_unit'],
      id: json['id'],
      name: json['name'],
      status: json['status'],
      timezone: json['timezone'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.createdAt;
    data['currency_code'] = this.currencyCode;
    data['currency_name'] = this.currencyName;
    data['distance_unit'] = this.distanceUnit;
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['timezone'] = this.timezone;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
