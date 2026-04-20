import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth_bloc.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/widgets/custom_text_button.dart';
import '../../../core/widgets/text_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            context.go('/home');
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.s(24.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.school, size: Responsive.s(80), color: Colors.blue),
                SizedBox(height: Responsive.s(24)),
                Text(
                  'ExamEase',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.s(32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.s(8)),
                Text(
                  'Your Path to Success',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Responsive.s(14),
                  ),
                ),
                SizedBox(height: Responsive.s(48)),
                TextController(
                  controller: _emailController,
                  hintText: 'Email Address',
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: Responsive.s(16)),
                TextController(
                  controller: _passwordController,
                  hintText: 'Password',
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: true,
                ),
                SizedBox(height: Responsive.s(24)),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextButton(
                          text: 'Login',
                          isLoading: state.isLoading,
                          onPressed: () {
                            if (_emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              context.read<AuthBloc>().add(
                                LoginRequested(
                                  _emailController.text,
                                  _passwordController.text,
                                ),
                              );
                            }
                          },
                          buttonColor: Colors.blue,
                          height: Responsive.s(50),
                        ),
                        SizedBox(height: Responsive.s(16)),
                        OutlinedButton.icon(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  context
                                      .read<AuthBloc>()
                                      .add(GoogleSignInRequested());
                                },
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.login),
                          ),
                          label: const Text('Sign in with Google'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: Responsive.s(12)),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: Responsive.s(16)),
                TextButton(
                  onPressed: () {
                    context.push('/register');
                  },
                  child: Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(fontSize: Responsive.s(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
