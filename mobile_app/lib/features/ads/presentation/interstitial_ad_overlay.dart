import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ad_bloc.dart';

class InterstitialAdOverlay extends StatefulWidget {
  final String placement;
  final VoidCallback onDismiss;

  const InterstitialAdOverlay({
    super.key,
    required this.placement,
    required this.onDismiss,
  });

  @override
  State<InterstitialAdOverlay> createState() => _InterstitialAdOverlayState();
}

class _InterstitialAdOverlayState extends State<InterstitialAdOverlay> {
  @override
  void initState() {
    super.initState();
    context.read<AdBloc>().add(FetchAdsRequested(widget.placement));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdBloc, AdState>(
      listener: (context, state) {
        if (state is AdLoaded && state.ads.isEmpty) {
          widget.onDismiss();
        } else if (state is AdFailure) {
          widget.onDismiss();
        }
      },
      builder: (context, state) {
        if (state is AdLoaded && state.ads.isNotEmpty) {
          final ad = state.ads.first;
          return Scaffold(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            body: Stack(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      if (ad.clickUrl != null) {
                        final url = Uri.parse(ad.clickUrl!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: ad.image.url,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            ad.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ad',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: widget.onDismiss,
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }
}
