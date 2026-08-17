import '../manage_imports.dart';

class EstimatePriceModel {
  List<ServicesListData>? data;
  PaginationModel? pagination;
  String? message;
  num? totalCoins;

  EstimatePriceModel({this.data, this.pagination, this.message, this.totalCoins});

  factory EstimatePriceModel.fromJson(Map<String, dynamic> json) {
    return EstimatePriceModel(
      data: json['data'] != null ? (json['data'] as List).map((i) => ServicesListData.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null,
      message: json['message'],
      totalCoins: json['total_coins'],
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
    data['message'] = this.message;
    data['total_coins'] = this.totalCoins;
    return data;
  }
}

class ServicesListData {
  num? adminCommission;
  num? baseFare;
  num? cancellationFee;
  num? capacity;
  String? commissionType;
  String? createdAt;
  num? discountAmount;
  num? distance;
  num? distancePrice;
  num? duration;
  num? fleetCommission;
  num? id;
  num? minimumDistance;
  num? minimumDistanceInKm;
  num? minimumFare;
  String? name;
  String? paymentMethod;
  num? perDistance;
  num? perMinuteDrive;
  num? perMinuteWait;
  num? fixed_charge;
  num? pickupDuration;
  num? regionId;
  String? serviceImage;
  var status;
  num? subtotal;
  num? timePrice;
  num? totalAmount;
  num? totalAmountAfterDiscount;
  num? coinsUsed;
  num? surgeAmount;
  String? updatedAt;
  num? waitDuration;
  num? waitingTimeLimit;
  String? startLatitude;
  String? startLongitude;
  String? startAddress;
  String? endLatitude;
  String? endLongitude;
  String? endAddress;
  CouponData? couponData;
  num? serviceId;
  String? description;

  String? distanceUnit;
  num? dropoffDistanceInKm;

  ServicesListData({
    this.adminCommission,
    this.baseFare,
    this.cancellationFee,
    this.capacity,
    this.commissionType,
    this.createdAt,
    this.discountAmount,
    this.distance,
    this.distancePrice,
    this.duration,
    this.fixed_charge,
    this.fleetCommission,
    this.id,
    this.minimumDistance,
    this.minimumDistanceInKm,
    this.minimumFare,
    this.name,
    this.paymentMethod,
    this.perDistance,
    this.perMinuteDrive,
    this.perMinuteWait,
    this.pickupDuration,
    this.regionId,
    this.serviceImage,
    this.status,
    this.subtotal,
    this.timePrice,
    this.totalAmount,
    this.totalAmountAfterDiscount,
    this.coinsUsed,
    this.surgeAmount,
    this.updatedAt,
    this.waitDuration,
    this.waitingTimeLimit,
    this.couponData,
    this.endAddress,
    this.endLongitude,
    this.startAddress,
    this.startLatitude,
    this.startLongitude,
    this.serviceId,
    this.endLatitude,
    this.description,
    this.distanceUnit,
    this.dropoffDistanceInKm,
  });

  factory ServicesListData.fromJson(Map<String, dynamic> json) {
    return ServicesListData(
      adminCommission: num.tryParse(json['admin_commission'].toString()),
      baseFare: num.tryParse(json['base_fare'].toString()),
      cancellationFee: num.tryParse(json['cancellation_fee'].toString()),
      // 😉 Sécurisé en int pour la capacité (ex: 4 places)
      capacity: num.tryParse(json['capacity'].toString())?.toInt(),
      commissionType: json['commission_type'],
      distanceUnit: json['distance_unit'],
      dropoffDistanceInKm: num.tryParse(json['dropoff_distance_in_km'].toString()),
      createdAt: json['created_at'],
      discountAmount: num.tryParse(json['discount_amount'].toString()) ?? 0,
      distance: num.tryParse(json['distance'].toString()),
      distancePrice: num.tryParse(json['distance_price'].toString()),
      duration: num.tryParse(json['duration'].toString()),
      fleetCommission: num.tryParse(json['fleet_commission'].toString()),
      // 😉 Sécurisé en int pour les IDs
      id: num.tryParse(json['id'].toString())?.toInt(),
      minimumDistance: num.tryParse(json['minimum_distance'].toString()),
      minimumDistanceInKm: num.tryParse(json['minimum_distance_in_km'].toString()),
      minimumFare: num.tryParse(json['minimum_fare'].toString()),
      name: json['name'],
      paymentMethod: json['payment_method'],
      perDistance: num.tryParse(json['per_distance'].toString()),
      perMinuteDrive: num.tryParse(json['per_minute_drive'].toString()),
      perMinuteWait: num.tryParse(json['per_minute_wait'].toString()),
      pickupDuration: num.tryParse(json['pickup_duration'].toString()),
      fixed_charge: num.tryParse(json['fixed_charge'].toString()),
      // 😉 Sécurisé en int pour l'ID de région
      regionId: num.tryParse(json['region_id'].toString())?.toInt(),
      serviceImage: json['service_image'],
      status: json['status'],
      subtotal: num.tryParse(json['subtotal'].toString()),
      timePrice: num.tryParse(json['time_price'].toString()),
      totalAmount: num.tryParse(json['total_amount'].toString()),
      totalAmountAfterDiscount: num.tryParse(json['total_amount_after_discount'].toString()),
      coinsUsed: num.tryParse(json['coins_used'].toString()),
      surgeAmount: num.tryParse(json['surge_amount'].toString()),
      updatedAt: json['updated_at'],
      waitDuration: num.tryParse(json['wait_duration'].toString()),
      waitingTimeLimit: num.tryParse(json['waiting_time_limit'].toString()),
      // 😉 Sécurisé en int pour l'ID du service
      serviceId: num.tryParse(json['service_id'].toString())?.toInt(),
      endAddress: json['end_address'],
      description: json['description'],
      couponData: json['coupon_data'] != null ? CouponData.fromJson(json['coupon_data']) : null,

      // 😉 Forcé en String propre pour éviter les conflits de types sur les coordonnées
      endLongitude: json['end_longitude']?.toString(),
      startAddress: json['start_address'],
      startLatitude: json['start_latitude']?.toString(),
      startLongitude: json['start_longitude']?.toString(),
      endLatitude: json['end_latitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin_commission'] = this.adminCommission;
    data['base_fare'] = this.baseFare;
    data['cancellation_fee'] = this.cancellationFee;
    data['fixed_charge'] = this.fixed_charge;
    data['distance_unit'] = this.distanceUnit;
    data['dropoff_distance_in_km'] = this.dropoffDistanceInKm;
    data['capacity'] = this.capacity;
    data['commission_type'] = this.commissionType;
    data['created_at'] = this.createdAt;
    data['discount_amount'] = this.discountAmount;
    data['distance'] = this.distance;
    data['distance_price'] = this.distancePrice;
    data['duration'] = this.duration;
    data['fleet_commission'] = this.fleetCommission;
    data['id'] = this.id;
    data['minimum_distance'] = this.minimumDistance;
    data['minimum_distance_in_km'] = this.minimumDistanceInKm;
    data['minimum_fare'] = this.minimumFare;
    data['name'] = this.name;
    data['payment_method'] = this.paymentMethod;
    data['per_distance'] = this.perDistance;
    data['per_minute_drive'] = this.perMinuteDrive;
    data['per_minute_wait'] = this.perMinuteWait;
    data['pickup_duration'] = this.pickupDuration;
    data['region_id'] = this.regionId;
    data['service_image'] = this.serviceImage;
    data['status'] = this.status;
    data['subtotal'] = this.subtotal;
    data['time_price'] = this.timePrice;
    data['total_amount'] = this.totalAmount;
    data['total_amount_after_discount'] = this.totalAmountAfterDiscount;
    data['coins_used'] = this.coinsUsed;
    data['surge_amount'] = this.surgeAmount;
    data['updated_at'] = this.updatedAt;
    data['wait_duration'] = this.waitDuration;
    data['waiting_time_limit'] = this.waitingTimeLimit;
    data['service_id'] = this.serviceId;
    data['start_address'] = this.startAddress;
    data['start_latitude'] = this.startLatitude;
    data['start_longitude'] = this.startLongitude;
    data['end_address'] = this.endAddress;
    data['end_latitude'] = this.endLatitude;
    data['end_longitude'] = this.endLongitude;
    data['service_id'] = this.serviceId;
    data['description'] = this.description;
    if (this.couponData != null) {
      data['coupon_data'] = this.couponData!.toJson();
    }
    return data;
  }
}
