import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ad_bloc.dart';

class BannerAdWidget extends StatefulWidget {
  final String placement;
  const BannerAdWidget({super.key, required this.placement});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    context.read<AdBloc>().add(FetchAdsRequested(widget.placement));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        if (state is AdLoaded && state.ads.isNotEmpty) {
          final ad = state.ads.first; // Show first for now
          return GestureDetector(
            onTap: () async {
              if (ad.clickUrl != null) {
                final url = Uri.parse(ad.clickUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              }
            },
            child: Container(
              width: double.infinity,
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(ad.image.url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
