import 'package:equatable/equatable.dart';

class MediaModel extends Equatable {
  final String documentId;
  final String name;
  final String mime;
  final String url;

  const MediaModel({
    required this.documentId,
    required this.name,
    required this.mime,
    required this.url,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      documentId: json['documentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mime: json['mime'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'name': name,
      'mime': mime,
      'url': url,
    };
  }

  MediaModel copyWith({
    String? documentId,
    String? name,
    String? mime,
    String? url,
  }) {
    return MediaModel(
      documentId: documentId ?? this.documentId,
      name: name ?? this.name,
      mime: mime ?? this.mime,
      url: url ?? this.url,
    );
  }

  factory MediaModel.empty() {
    return const MediaModel(
      documentId: '',
      name: '',
      mime: '',
      url: '',
    );
  }

  @override
  List<Object?> get props => [documentId, name, mime, url];
}
