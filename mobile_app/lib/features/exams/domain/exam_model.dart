import 'package:equatable/equatable.dart';

class ExamModel extends Equatable {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? icon;
  final String? bannerImage;
  final String? themeColor;
  final bool isActive;
  final int orderIndex;

  const ExamModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.icon,
    this.bannerImage,
    this.themeColor,
    this.isActive = true,
    this.orderIndex = 0,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      bannerImage: json['bannerImage'] as String?,
      themeColor: json['themeColor'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'icon': icon,
      'bannerImage': bannerImage,
      'themeColor': themeColor,
      'isActive': isActive,
      'orderIndex': orderIndex,
    };
  }

  ExamModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? description,
    String? icon,
    String? bannerImage,
    String? themeColor,
    bool? isActive,
    int? orderIndex,
  }) {
    return ExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      bannerImage: bannerImage ?? this.bannerImage,
      themeColor: themeColor ?? this.themeColor,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  factory ExamModel.empty() {
    return const ExamModel(id: '', title: '', slug: '');
  }

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    description,
    icon,
    bannerImage,
    themeColor,
    isActive,
    orderIndex,
  ];
}
