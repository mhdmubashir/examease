import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/blocs/app_config_bloc.dart';
import '../presentation/auth_bloc.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/widgets/custom_text_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppConfigBloc>().add(AppConfigFetchStarted());
  }

  void _navigate(
    BuildContext context,
    AppConfigState configState,
    AuthState authState,
  ) {
    if (configState is AppConfigSuccess && !authState.isLoading) {
      if (authState.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppConfigBloc, AppConfigState>(
          listener: (context, configState) {
            if (configState is AppConfigFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(configState.message)));
            }
            _navigate(context, configState, context.read<AuthBloc>().state);
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            _navigate(context, context.read<AppConfigBloc>().state, authState);
          },
        ),
      ],
      child: Scaffold(
        body: Center(
          child: BlocBuilder<AppConfigBloc, AppConfigState>(
            builder: (context, state) {
              if (state is AppConfigMaintenance) {
                return _buildErrorScreen(
                  icon: Icons.construction,
                  title: 'Maintenance Mode',
                  message: state.message,
                );
              }
              if (state is AppConfigUpdateRequired) {
                return _buildErrorScreen(
                  icon: Icons.update,
                  title: 'Update Required',
                  message:
                      'A new version is available. Please update to continue.',
                  action: CustomTextButton(
                    text: 'Update Now',
                    onPressed: () {}, // Redirect to store
                    buttonColor: Colors.blue,
                    height: Responsive.s(45),
                  ),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: Responsive.s(80),
                    color: Colors.blue,
                  ),
                  SizedBox(height: Responsive.s(24)),
                  Text(
                    'ExamEase',
                    style: TextStyle(
                      fontSize: Responsive.s(32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.s(48)),
                  const CircularProgressIndicator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Padding(
      padding: EdgeInsets.all(Responsive.s(32.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: Responsive.s(80), color: Colors.orange),
          SizedBox(height: Responsive.s(24)),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.s(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.s(16)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: Responsive.s(16), color: Colors.grey),
          ),
          if (action != null) ...[SizedBox(height: Responsive.s(32)), action],
          SizedBox(height: Responsive.s(24)),
          CustomTextButton(
            text: 'Try Again',
            onPressed: () =>
                context.read<AppConfigBloc>().add(AppConfigFetchStarted()),
            buttonColor: Colors.transparent,
            textStyle: TextStyle(
              color: Colors.blue,
              fontSize: Responsive.s(14),
              fontWeight: FontWeight.w600,
            ),
            height: Responsive.s(40),
          ),
        ],
      ),
    );
  }
}
