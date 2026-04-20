import '../../../core/network/api_response.dart';
import 'payment_model.dart';
import 'payment_repository.dart';

class CreateOrderUseCase {
  final PaymentRepository repository;

  CreateOrderUseCase(this.repository);

  Future<ApiResponse<OrderModel>> call({
    required String moduleId,
    required double amount,
  }) async {
    final response = await repository.createOrder(
      moduleId: moduleId,
      amount: amount,
    );
    if (response.status && response.data != null) {
      return ApiResponse(status: true, data: response.data);
    }
    return ApiResponse(status: false, message: response.message);
  }
}
