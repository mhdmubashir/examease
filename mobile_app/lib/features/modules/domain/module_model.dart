import 'package:equatable/equatable.dart';

class ModuleModel extends Equatable {
  final String id;
  final String examId;
  final String title;
  final String? description;
  final String? thumbnail;
  final double price;
  final double discountPrice;
  final String accessType;
  final bool isBundle;
  final List<String> includedModules;
  final int validityDays;
  final bool isActive;

  const ModuleModel({
    required this.id,
    required this.examId,
    required this.title,
    this.description,
    this.thumbnail,
    required this.price,
    this.discountPrice = 0.0,
    this.accessType = 'PAID',
    this.isBundle = false,
    this.includedModules = const [],
    this.validityDays = 0,
    this.isActive = true,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      examId: json['examId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble() ?? 0.0,
      accessType: json['accessType'] as String? ?? 'PAID',
      isBundle: json['isBundle'] as bool? ?? false,
      includedModules:
          (json['includedModules'] as List?)?.map((e) => e as String).toList() ??
          const [],
      validityDays: (json['validityDays'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examId': examId,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'price': price,
      'discountPrice': discountPrice,
      'accessType': accessType,
      'isBundle': isBundle,
      'includedModules': includedModules,
      'validityDays': validityDays,
      'isActive': isActive,
    };
  }

  ModuleModel copyWith({
    String? id,
    String? examId,
    String? title,
    String? description,
    String? thumbnail,
    double? price,
    double? discountPrice,
    String? accessType,
    bool? isBundle,
    List<String>? includedModules,
    int? validityDays,
    bool? isActive,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      accessType: accessType ?? this.accessType,
      isBundle: isBundle ?? this.isBundle,
      includedModules: includedModules ?? this.includedModules,
      validityDays: validityDays ?? this.validityDays,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Whether this module is free (by accessType).
  bool get isFree => accessType == 'FREE';

  /// Whether this has lifetime validity.
  bool get isLifetime => validityDays == 0;

  factory ModuleModel.empty() {
    return const ModuleModel(id: '', examId: '', title: '', price: 0.0);
  }

  @override
  List<Object?> get props => [
    id,
    examId,
    title,
    description,
    thumbnail,
    price,
    discountPrice,
    accessType,
    isBundle,
    includedModules,
    validityDays,
    isActive,
  ];
}
