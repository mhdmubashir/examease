import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth_bloc.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/widgets/custom_text_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification successful! You can now login.'),
                backgroundColor: Colors.green,
              ),
            );
            // Go to login as requested
            context.go('/login');
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(Responsive.s(24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Check your email',
                  style: TextStyle(
                    fontSize: Responsive.s(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.s(8)),
                Text(
                  'We sent a 4-digit code to ${widget.email}',
                  style: TextStyle(color: Colors.grey, fontSize: Responsive.s(14)),
                ),
                SizedBox(height: Responsive.s(48)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: Responsive.s(60),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.s(48)),
                CustomTextButton(
                  text: 'Verify',
                  isLoading: state.isLoading,
                  onPressed: () {
                    if (_otp.length == 4) {
                      context.read<AuthBloc>().add(
                            VerifyOtpRequested(widget.email, _otp),
                          );
                    }
                  },
                  buttonColor: Colors.blue,
                  height: Responsive.s(50),
                ),
                SizedBox(height: Responsive.s(16)),
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          context
                              .read<AuthBloc>()
                              .add(ResendOtpRequested(widget.email));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP Resent!')),
                          );
                        },
                  child: const Text('Resend Code'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
