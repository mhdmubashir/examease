import '../../../core/network/api_response.dart';
import 'payment_repository.dart';

class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<ApiResponse<void>> call({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    return await repository.verifyPayment(
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }
}
