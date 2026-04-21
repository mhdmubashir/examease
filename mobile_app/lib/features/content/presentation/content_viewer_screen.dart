import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../mock_tests/presentation/mock_test_screen.dart';
import '../../../core/widgets/helper/responsive.dart';
import '../../../core/widgets/custom_text_button.dart';
import '../../../core/network/service_locator.dart';
import '../domain/content_repository.dart';

class ContentViewerScreen extends StatefulWidget {
  final String contentId;
  final String contentTitle;
  final String? contentUrl;
  final String? contentType;
  final String? s3Key; // S3 key for video content
  final String? metadata; // Used for markdown content

  const ContentViewerScreen({
    super.key,
    required this.contentId,
    required this.contentTitle,
    this.contentUrl,
    this.contentType,
    this.s3Key,
    this.metadata,
  });

  @override
  State<ContentViewerScreen> createState() => _ContentViewerScreenState();
}

class _ContentViewerScreenState extends State<ContentViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contentTitle,
          style: TextStyle(fontSize: Responsive.s(18)),
        ),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.contentType?.toUpperCase() == 'MOCK_TEST') {
      return MockTestScreen(
        contentId: widget.contentId,
        contentTitle: widget.contentTitle,
      );
    }

    // For S3-hosted videos, use the authenticated stream player
    if (widget.contentType?.toUpperCase() == 'VIDEO') {
      if (widget.s3Key != null && widget.s3Key!.isNotEmpty) {
        return _S3VideoPlayer(contentId: widget.contentId);
      }
      // Fallback for legacy YouTube/direct URL videos
      if (widget.contentUrl != null && widget.contentUrl!.isNotEmpty) {
        return _VideoPlayer(url: widget.contentUrl!);
      }
      return Center(
        child: Text(
          'No video available.',
          style: TextStyle(fontSize: Responsive.s(16)),
        ),
      );
    }

    if (widget.contentType?.toUpperCase() != 'NOTE' && widget.contentType?.toUpperCase() != 'STUDY_MATERIAL') {
      if (widget.contentUrl == null || widget.contentUrl!.isEmpty) {
        return Center(
          child: Text(
            'No content URL provided.',
            style: TextStyle(fontSize: Responsive.s(16)),
          ),
        );
      }
    }

    switch (widget.contentType?.toUpperCase()) {
      case 'PDF':
        return _PdfViewer(
          contentId: widget.contentId,
          url: widget.contentUrl!,
        );
      case 'NOTE':
      case 'STUDY_MATERIAL':
        return _StudyMaterial(metadata: widget.metadata);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article, size: Responsive.s(80), color: Colors.blue),
              SizedBox(height: Responsive.s(24)),
              Text(
                widget.contentTitle,
                style: TextStyle(
                  fontSize: Responsive.s(24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.s(16)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.s(32.0)),
                child: Text(
                  'This content type is not yet supported natively.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Responsive.s(14),
                  ),
                ),
              ),
              SizedBox(height: Responsive.s(48)),
              CustomTextButton(
                text: 'Go Back',
                onPressed: () => Navigator.of(context).pop(),
                buttonColor: Colors.blue,
                width: Responsive.s(140),
                height: Responsive.s(45),
              ),
            ],
          ),
        );
    }
  }
}

/// S3 Video Player — Fetches a presigned URL via the backend,
/// then plays the video using Chewie/video_player.
class _S3VideoPlayer extends StatefulWidget {
  final String contentId;
  const _S3VideoPlayer({required this.contentId});

  @override
  State<_S3VideoPlayer> createState() => _S3VideoPlayerState();
}

class _S3VideoPlayerState extends State<_S3VideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndPlay();
  }

  Future<void> _fetchAndPlay() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch authenticated presigned URL from backend
      final contentRepo = sl<ContentRepository>();
      final response = await contentRepo.getVideoStreamUrl(widget.contentId);

      if (!response.status || response.data == null || response.data!.isEmpty) {
        setState(() {
          _error = response.message ?? 'Failed to load video URL';
          _isLoading = false;
        });
        return;
      }

      final streamUrl = response.data!;

      // Initialize video player with the presigned URL
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
      );
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error playing video',
                  style: TextStyle(
                    fontSize: Responsive.s(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Responsive.s(12),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load video: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _retry() {
    _disposeControllers();
    _fetchAndPlay();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: Responsive.s(16)),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.grey, fontSize: Responsive.s(14)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.s(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: Responsive.s(64), color: Colors.grey),
              SizedBox(height: Responsive.s(16)),
              Text(
                'Unable to load video',
                style: TextStyle(
                  fontSize: Responsive.s(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Responsive.s(8)),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: Responsive.s(13),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Responsive.s(24)),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

/// Legacy video player for direct URL videos (YouTube, etc.)
class _VideoPlayer extends StatefulWidget {
  final String url;
  const _VideoPlayer({required this.url});

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? Chewie(controller: _chewieController!)
        : const Center(child: CircularProgressIndicator());
  }
}

class _PdfViewer extends StatefulWidget {
  final String contentId;
  final String url;
  const _PdfViewer({required this.contentId, required this.url});

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final contentRepo = sl<ContentRepository>();
      final response = await contentRepo.getDocumentStreamUrl(widget.contentId);

      if (!response.status || response.data == null || response.data!.isEmpty) {
        throw Exception(response.message ?? 'Failed to get PDF URL');
      }

      final freshUrl = response.data!;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/pdf_${widget.contentId}.pdf');

      // Always download using the fresh URL, replacing any old file
      await Dio().download(freshUrl, file.path);

      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: Responsive.s(16)),
            Text(
              'Downloading PDF...',
              style: TextStyle(color: Colors.grey, fontSize: Responsive.s(14)),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.s(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.red, size: Responsive.s(48)),
              SizedBox(height: Responsive.s(16)),
              Text('Failed to load PDF'),
              SizedBox(height: Responsive.s(8)),
              Text(
                _error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.s(16)),
              ElevatedButton(
                onPressed: () => _downloadPdf(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_localPath == null) {
      return const Center(child: Text('Failed to load PDF'));
    }

    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onRender: (pages) {
        debugPrint('PDF Rendered with $pages pages');
      },
      onError: (error) {
        setState(() {
          _error = error.toString();
        });
      },
    );
  }
}

class _StudyMaterial extends StatelessWidget {
  final String? metadata;
  const _StudyMaterial({this.metadata});

  @override
  Widget build(BuildContext context) {
    if (metadata == null || metadata!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.s(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.grey, size: 48),
              const SizedBox(height: 16),
              const Text('No content found for this note.'),
            ],
          ),
        ),
      );
    }
    
    return Markdown(
      data: metadata!,
      selectable: true,
      padding: EdgeInsets.all(Responsive.s(16)),
    );
  }
}

