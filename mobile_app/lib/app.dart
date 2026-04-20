import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/router.dart';
import 'core/network/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_bloc.dart';
import 'features/exams/presentation/exam_bloc.dart';
import 'features/modules/presentation/module_bloc.dart';
import 'features/content/presentation/content_bloc.dart';
import 'features/mock_tests/presentation/mock_test_bloc.dart';
import 'features/payments/presentation/payment_bloc.dart';
import 'features/ads/presentation/ad_bloc.dart';
import 'core/blocs/app_config_bloc.dart';
import 'core/blocs/network_bloc.dart';
import 'core/widgets/network_aware_widget.dart';

import '../../../core/widgets/helper/responsive.dart';

class ExamEaseApp extends StatelessWidget {
  const ExamEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppConfigBloc>(
          create: (context) =>
              sl<AppConfigBloc>()..add(AppConfigFetchStarted()),
        ),
        BlocProvider<NetworkBloc>(create: (context) => sl<NetworkBloc>()),
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<ExamBloc>(create: (context) => sl<ExamBloc>()),
        BlocProvider<ModuleBloc>(create: (context) => sl<ModuleBloc>()),
        BlocProvider<PaymentBloc>(create: (context) => sl<PaymentBloc>()),
        BlocProvider<AdBloc>(create: (context) => sl<AdBloc>()),
        BlocProvider<ContentBloc>(create: (context) => sl<ContentBloc>()),
        BlocProvider<MockTestBloc>(create: (context) => sl<MockTestBloc>()),
      ],
      child: BlocBuilder<AppConfigBloc, AppConfigState>(
        builder: (context, state) {
          String? primaryColor;
          if (state is AppConfigSuccess) {
            primaryColor = state.config.primaryColor;
          }

          return MaterialApp.router(
            title: 'ExamEase',
            debugShowCheckedModeBanner: false,
            theme: AppThemeMapper.createTheme(primaryColor),
            routerConfig: router,
            builder: (context, child) {
              // Now this context is inside MaterialApp, providing Directionality and Theme
              Responsive.init(context);
              return NetworkAwareWidget(child: child!);
            },
          );
        },
      ),
    );
  }
}
