import '../../../core/services/main_service.dart';
import '../../../core/network/api_response.dart';
import '../domain/payment_model.dart';
import '../domain/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final MainService mainService;

  PaymentRepositoryImpl(this.mainService);

  @override
  Future<ApiResponse<OrderModel>> createOrder({
    required String moduleId,
    required double amount,
  }) async {
    return await mainService.post(
      '/payments/create-order',
      data: {'moduleId': moduleId, 'amount': amount},
      fromJsonT: (json) => OrderModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    return await mainService.post(
      '/payments/verify-payment',
      data: {
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
      },
      fromJsonT: (json) {},
    );
  }
}
