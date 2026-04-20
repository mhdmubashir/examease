import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String role;
  final List<String> purchasedItems;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.purchasedItems = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      purchasedItems:
          (json['purchasedItems'] as List?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'role': role,
      'purchasedItems': purchasedItems,
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    List<String>? purchasedItems,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      purchasedItems: purchasedItems ?? this.purchasedItems,
    );
  }

  factory UserModel.empty() {
    return const UserModel(
      userId: '',
      name: '',
      email: '',
      role: '',
      purchasedItems: [],
    );
  }

  @override
  List<Object?> get props => [userId, name, email, role, purchasedItems];
}
