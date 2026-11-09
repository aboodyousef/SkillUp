import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerView({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  String? _error;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.videoUrl;

    if (url.isEmpty) {
      setState(() => _error = 'noVideoUrlProvided'.tr);
      return;
    }

    try {
      late final VideoPlayerController c;

      if (url.startsWith('assets/')) {
        debugPrint('VideoPlayer: loading asset -> $url');
        c = VideoPlayerController.asset(url);
      } else {
        debugPrint('VideoPlayer: loading network -> $url');
        c = VideoPlayerController.networkUrl(Uri.parse(url));
      }

      _controller = c;

      await c.initialize();
      await Future.delayed(const Duration(milliseconds: 100));
      c.setLooping(false);
      await c.play();

      if (!mounted) return;
      setState(() {
        _isReady = true;
        _error = null;
      });
    } catch (e) {
      debugPrint('VideoPlayer error: $e');
      if (!mounted) return;
      setState(() {
        _isReady = false;
        _error = 'failedToLoadVideo'.tr;
      });
    }
  }

  Future<void> _retry() async {
    if (_isRetrying) return;
    _isRetrying = true;

    _controller?.pause();
    _controller?.dispose();
    _controller = null;

    setState(() {
      _isReady = false;
      _error = null;
    });

    await _init();
    _isRetrying = false;
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? "${two(h)}:${two(m)}:${two(s)}" : "${two(m)}:${two(s)}";
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            c?.pause();
            Get.back();
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _error != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white70, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: Text('retry'.tr),
                    ),
                  ],
                )
              : (!_isReady || c == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'loadingVideo'.tr,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: c.value.aspectRatio,
                              child: VideoPlayer(c),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Column(
                            children: [
                              VideoProgressIndicator(c, allowScrubbing: true),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fmt(c.value.position),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  Text(
                                    _fmt(c.value.duration),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    iconSize: 36,
                                    color: Colors.white,
                                    icon: const Icon(Icons.replay_10),
                                    onPressed: () {
                                      final current = c.value.position;
                                      final target = current -
                                          const Duration(seconds: 10);
                                      c.seekTo(target < Duration.zero
                                          ? Duration.zero
                                          : target);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    iconSize: 56,
                                    color: Colors.white,
                                    icon: Icon(
                                      c.value.isPlaying
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        c.value.isPlaying
                                            ? c.pause()
                                            : c.play();
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    iconSize: 36,
                                    color: Colors.white,
                                    icon: const Icon(Icons.forward_10),
                                    onPressed: () {
                                      final current = c.value.position;
                                      final target =
                                          current + const Duration(seconds: 10);
                                      final end = c.value.duration;
                                      c.seekTo(
                                          target > end ? end : target);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
