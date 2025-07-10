class ServiceModel {
  final String? id;
  final String title;
  final String? name;
  final String? description;
  final double price;
  final String imageUrl;
  final String? categoryId;
  final String? artistId;

  ServiceModel({
    this.id,
    required this.title,
    this.name,
    this.description,
    required this.price,
    required this.imageUrl,
    this.categoryId,
    this.artistId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ??
          json['name']?.toString() ??
          json['serviceName']?.toString() ??
          '',
      name: json['name']?.toString() ?? json['serviceName']?.toString(),
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      artistId: json['artistId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'artistId': artistId,
    };
  }
}

class PromotionModel {
  final String? id;
  final String title;
  final String description;
  final double discountPercent;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? serviceId;
  final String? serviceName;

  PromotionModel({
    this.id,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.serviceId,
    this.serviceName,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      isActive: json['isActive'] == true,
      serviceId: json['serviceId']?.toString(),
      serviceName: json['serviceName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountPercent': discountPercent,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'serviceId': serviceId,
      'serviceName': serviceName,
    };
  }
}
