import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../domain/create_order_usecase.dart';
import '../domain/verify_payment_usecase.dart';

// Events
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

class PaymentStarted extends PaymentEvent {
  final String moduleId;
  final double amount;
  final String userEmail;
  final String userPhone;

  const PaymentStarted({
    required this.moduleId,
    required this.amount,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  List<Object?> get props => [moduleId, amount, userEmail, userPhone];
}

class _PaymentSuccessInternal extends PaymentEvent {
  final PaymentSuccessResponse response;
  const _PaymentSuccessInternal(this.response);
}

class _PaymentErrorInternal extends PaymentEvent {
  final PaymentFailureResponse response;
  const _PaymentErrorInternal(this.response);
}

// States
abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String paymentId;
  final String? message;
  const PaymentSuccess(this.paymentId, {this.message});
  @override
  List<Object?> get props => [paymentId, message];
}

class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);
}

// Bloc
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderUseCase createOrderUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final Razorpay _razorpay = Razorpay();

  PaymentBloc(this.createOrderUseCase, this.verifyPaymentUseCase)
    : super(PaymentInitial()) {
    on<PaymentStarted>(_onPaymentStarted);
    on<_PaymentSuccessInternal>(_onPaymentSuccess);
    on<_PaymentErrorInternal>(_onPaymentError);

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    add(_PaymentSuccessInternal(response));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    add(_PaymentErrorInternal(response));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  Future<void> _onPaymentStarted(
    PaymentStarted event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final response = await createOrderUseCase(
        moduleId: event.moduleId,
        amount: event.amount,
      );

      if (response.status && response.data != null) {
        final order = response.data!;

        var options = {
          'key': 'rzp_test_YOUR_KEY_HERE', // Should come from AppConfig
          'amount': order.amount,
          'name': 'ExamEase',
          'order_id': order.id,
          'description': 'Module Purchase',
          'prefill': {'contact': event.userPhone, 'email': event.userEmail},
          'external': {
            'wallets': ['paytm'],
          },
        };

        _razorpay.open(options);
      } else {
        emit(PaymentFailure(response.message ?? 'Failed to create order'));
      }
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _onPaymentSuccess(
    _PaymentSuccessInternal event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final response = await verifyPaymentUseCase(
        paymentId: event.response.paymentId ?? '',
        orderId: event.response.orderId ?? '',
        signature: event.response.signature ?? '',
      );

      if (response.status) {
        emit(
          PaymentSuccess(
            event.response.paymentId ?? '',
            message: response.message,
          ),
        );
      } else {
        emit(PaymentFailure(response.message ?? 'Payment verification failed'));
      }
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  void _onPaymentError(
    _PaymentErrorInternal event,
    Emitter<PaymentState> emit,
  ) {
    emit(PaymentFailure(event.response.message ?? 'Payment Failed'));
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
