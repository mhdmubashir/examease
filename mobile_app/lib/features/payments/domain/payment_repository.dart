import '../../../core/network/api_response.dart';
import '../domain/payment_model.dart';

abstract class PaymentRepository {
  Future<ApiResponse<OrderModel>> createOrder({
    required String moduleId,
    required double amount,
  });

  Future<ApiResponse<void>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
}
