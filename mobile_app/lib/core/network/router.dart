import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/exams/presentation/home_screen.dart';
import '../../features/modules/presentation/module_screen.dart';
import '../../features/content/presentation/content_list_screen.dart';
import '../../features/content/presentation/content_viewer_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => OtpScreen(email: state.extra as String),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'modules/:examId',
          builder: (context, state) => ModuleScreen(
            examId: state.pathParameters['examId']!,
            examTitle: state.uri.queryParameters['title'] ?? 'Modules',
          ),
          routes: [
            GoRoute(
              path: 'contents/:moduleId',
              builder: (context, state) => ContentListScreen(
                moduleId: state.pathParameters['moduleId']!,
                moduleTitle: state.uri.queryParameters['title'] ?? 'Content',
              ),
              routes: [
                GoRoute(
                  path: 'view/:contentId',
                  builder: (context, state) => ContentViewerScreen(
                    contentId: state.pathParameters['contentId']!,
                    contentTitle:
                        state.uri.queryParameters['title'] ?? 'Viewer',
                    contentUrl: state.uri.queryParameters['url'],
                    contentType: state.uri.queryParameters['type'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
