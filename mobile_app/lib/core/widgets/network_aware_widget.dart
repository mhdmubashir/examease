import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/network_bloc.dart';

/// Wraps the app/screen to show a persistent offline banner when
/// the device loses internet connectivity.
///
/// Usage:
/// ```dart
/// NetworkAwareWidget(
///   onReconnected: () => bloc.add(RefreshDataEvent()),
///   child: YourScreen(),
/// )
/// ```
class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  /// Called when the network transitions from disconnected → connected.
  /// Use this to trigger API re-fetches.
  final VoidCallback? onReconnected;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.onReconnected,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  bool _wasDisconnected = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkBloc, NetworkState>(
      listener: (context, state) {
        if (state is NetworkDisconnected) {
          _wasDisconnected = true;
          _animController.forward();
        } else if (state is NetworkConnected) {
          _animController.reverse();
          // Trigger re-fetch callback when reconnecting after a disconnect
          if (_wasDisconnected) {
            _wasDisconnected = false;
            widget.onReconnected?.call();
          }
        }
      },
      child: Stack(
        children: [
          // Main content
          widget.child,

          // Offline banner (slides in from top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 4,
                    bottom: 10,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'No Internet Connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
