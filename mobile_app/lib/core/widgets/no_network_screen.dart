import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/network_bloc.dart';
import 'helper/responsive.dart';

/// Full-screen fallback shown when there's no cached data
/// and the device is offline.
class NoNetworkScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NoNetworkScreen({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.s(32)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Airplane/WiFi icon
                Container(
                  padding: EdgeInsets.all(Responsive.s(24)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: Responsive.s(64),
                    color: theme.colorScheme.error,
                  ),
                ),

                SizedBox(height: Responsive.s(32)),

                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: Responsive.s(22),
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: Responsive.s(12)),

                Text(
                  message ??
                      'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.s(14),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),

                SizedBox(height: Responsive.s(40)),

                // Retry button
                SizedBox(
                  width: Responsive.s(200),
                  height: Responsive.s(48),
                  child: ElevatedButton.icon(
                    onPressed: onRetry ??
                        () {
                          context
                              .read<NetworkBloc>()
                              .add(NetworkCheckRequested());
                        },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Responsive.s(16)),

                // Connection status listener
                BlocBuilder<NetworkBloc, NetworkState>(
                  builder: (context, state) {
                    if (state is NetworkConnected) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: Responsive.s(16),
                          ),
                          SizedBox(width: Responsive.s(6)),
                          Text(
                            'Connected! Loading...',
                            style: TextStyle(
                              fontSize: Responsive.s(13),
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
