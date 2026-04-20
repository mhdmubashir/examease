import 'package:equatable/equatable.dart';
import '../../../core/models/media_model.dart';

class AdModel extends Equatable {
  final String id;
  final String title;
  final String placement;
  final MediaModel image;
  final String? clickUrl;
  final bool isActive;

  const AdModel({
    required this.id,
    required this.title,
    required this.placement,
    required this.image,
    this.clickUrl,
    required this.isActive,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      image: json['image'] != null 
          ? MediaModel.fromJson(json['image'] as Map<String, dynamic>)
          : json['imageUrl'] != null
              ? MediaModel(documentId: '', name: '', mime: '', url: json['imageUrl'] as String)
              : MediaModel.empty(),
      clickUrl: json['clickUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'placement': placement,
      'image': image.toJson(),
      'clickUrl': clickUrl,
      'isActive': isActive,
    };
  }

  AdModel copyWith({
    String? id,
    String? title,
    String? placement,
    MediaModel? image,
    String? clickUrl,
    bool? isActive,
  }) {
    return AdModel(
      id: id ?? this.id,
      title: title ?? this.title,
      placement: placement ?? this.placement,
      image: image ?? this.image,
      clickUrl: clickUrl ?? this.clickUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  factory AdModel.empty() {
    return AdModel(
      id: '',
      title: '',
      placement: '',
      image: MediaModel.empty(),
      isActive: true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    placement,
    image,
    clickUrl,
    isActive,
  ];
}
