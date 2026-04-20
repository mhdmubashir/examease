import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String id;
  final String entity;
  final int amount;
  final int amountPaid;
  final int amountDue;
  final String currency;
  final String receipt;
  final String status;
  final int attempts;
  final int createdAt;

  const OrderModel({
    required this.id,
    required this.entity,
    required this.amount,
    required this.amountPaid,
    required this.amountDue,
    required this.currency,
    required this.receipt,
    required this.status,
    required this.attempts,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      entity: json['entity'] as String? ?? 'order',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      amountPaid: (json['amount_paid'] as num?)?.toInt() ?? 0,
      amountDue: (json['amount_due'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      receipt: json['receipt'] as String? ?? '',
      status: json['status'] as String? ?? 'created',
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity': entity,
      'amount': amount,
      'amount_paid': amountPaid,
      'amount_due': amountDue,
      'currency': currency,
      'receipt': receipt,
      'status': status,
      'attempts': attempts,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    entity,
    amount,
    amountPaid,
    amountDue,
    currency,
    receipt,
    status,
    attempts,
    createdAt,
  ];
}
