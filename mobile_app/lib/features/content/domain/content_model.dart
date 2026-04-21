import 'package:equatable/equatable.dart';
import '../../../core/models/media_model.dart';

class ContentModel extends Equatable {
  final String id;
  final String title;
  final String contentType; // PDF, VIDEO, MOCK_TEST, NOTE
  final String contentUrl;
  final String? s3Key; // S3 object key for VIDEO content
  final MediaModel? media; // Standardized media object
  final String? metadata;
  final bool isActive;

  const ContentModel({
    required this.id,
    required this.title,
    required this.contentType,
    required this.contentUrl,
    this.s3Key,
    this.media,
    this.metadata,
    this.isActive = true,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      contentUrl: json['contentUrl'] as String? ?? '',
      s3Key: json['s3Key'] as String?,
      media: json['media'] != null ? MediaModel.fromJson(json['media'] as Map<String, dynamic>) : null,
      metadata: json['metadata']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'contentType': contentType,
      'contentUrl': contentUrl,
      's3Key': s3Key,
      'media': media?.toJson(),
      'metadata': metadata,
      'isActive': isActive,
    };
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? contentType,
    String? contentUrl,
    String? s3Key,
    MediaModel? media,
    String? metadata,
    bool? isActive,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      contentUrl: contentUrl ?? this.contentUrl,
      s3Key: s3Key ?? this.s3Key,
      media: media ?? this.media,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Parse backend response format into ContentModel.
  static ContentModel fromBackend(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    // Parse standardized media if it exists in 'data'
    MediaModel? media;
    if (data['media'] != null) {
      media = MediaModel.fromJson(data['media'] as Map<String, dynamic>);
    }

    String url = '';
    String? s3Key;

    if (media != null) {
      url = media.url;
      s3Key = media.documentId;
    } else {
      // Legacy parsing logic
      if (json['contentType'] == 'PDF') {
        url = data['fileUrl'] ?? data['pdfUrl'] ?? '';
      } else if (json['contentType'] == 'VIDEO') {
        s3Key = data['s3Key'] as String?;
        if (s3Key == null || s3Key.isEmpty) {
          url = data['videoUrl'] ?? '';
        }
      }
    }

    String? metadataString;
    if (json['metadata'] != null) {
      metadataString = json['metadata'].toString();
    } else if (data['content'] != null) {
      metadataString = data['content'].toString();
    } else if (json['data'] != null) {
      metadataString = json['data'].toString();
    }

    return ContentModel.fromJson({
      ...json,
      'id': json['_id'],
      'contentUrl': url,
      's3Key': s3Key,
      'media': media?.toJson(),
      'metadata': metadataString,
    });
  }

  /// Whether this video uses S3 storage (vs legacy YouTube URL).
  bool get isS3Video => (contentType == 'VIDEO' && s3Key != null && s3Key!.isNotEmpty) || (media != null && contentType == 'VIDEO');

  factory ContentModel.empty() {
    return const ContentModel(
      id: '',
      title: '',
      contentType: '',
      contentUrl: '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    contentType,
    contentUrl,
    s3Key,
    media,
    metadata,
    isActive,
  ];
}
