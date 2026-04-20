import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth_bloc.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/widgets/custom_text_button.dart';
import '../../../core/widgets/text_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isOtpSent) {
            context.push('/otp', extra: _emailController.text);
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.s(24.0)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join ExamEase',
                  style: TextStyle(
                    fontSize: Responsive.s(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.s(8)),
                Text(
                  'Fill in your details to get started',
                  style: TextStyle(color: Colors.grey, fontSize: Responsive.s(14)),
                ),
                SizedBox(height: Responsive.s(32)),
                TextController(
                  controller: _nameController,
                  hintText: 'Full Name',
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                SizedBox(height: Responsive.s(16)),
                TextController(
                  controller: _emailController,
                  hintText: 'Email Address',
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.s(16)),
                TextController(
                  controller: _phoneController,
                  hintText: '+91XXXXXXXXXX',
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) return 'Phone is required';
                    if (!RegExp(r'^\+91[6-9]\d{9}$').hasMatch(value)) {
                      return 'Enter valid Indian number (+91XXXXXXXXXX)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.s(16)),
                TextController(
                  controller: _passwordController,
                  hintText: 'Password',
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: true,
                  validator: (value) =>
                      value!.length < 6 ? 'Password min 6 characters' : null,
                ),
                SizedBox(height: Responsive.s(16)),
                TextController(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_clock),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.s(32)),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomTextButton(
                      text: 'Sign Up',
                      isLoading: state.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                RegisterRequested(
                                  _nameController.text,
                                  _emailController.text,
                                  _phoneController.text,
                                  _passwordController.text,
                                ),
                              );
                        }
                      },
                      buttonColor: Colors.blue,
                      height: Responsive.s(50),
                    );
                  },
                ),
                SizedBox(height: Responsive.s(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
