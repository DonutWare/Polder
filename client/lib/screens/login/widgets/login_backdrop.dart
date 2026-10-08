import "dart:async";

import "package:flutter/material.dart";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/branding.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/widgets/shared/server_icon.dart";

class LoginBackdrop extends ConsumerStatefulWidget {
  const LoginBackdrop({super.key});

  static const interval = Duration(seconds: 8);

  @override
  ConsumerState<LoginBackdrop> createState() => _LoginBackdropState();
}

class _LoginBackdropState extends ConsumerState<LoginBackdrop> {
  Timer? _timer;
  var _index = 0;
  String? _prefetched;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(LoginBackdrop.interval, (_) => setState(() => _index++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingProvider);
    final backgrounds = branding.backgrounds;
    if (branding.serverUrl == null || backgrounds.isEmpty) return const SizedBox.shrink();
    final current = backgrounds[_index % backgrounds.length];
    if (backgrounds.length > 1) _prefetch(branding, backgrounds[(_index + 1) % backgrounds.length]);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1200),
      child: SizedBox.expand(
        key: ValueKey(current.id),
        child: ServerImageView(url: branding.backgroundUrl(current), image: current, fit: BoxFit.cover),
      ),
    );
  }

  void _prefetch(Branding branding, ServerImage next) {
    if (_prefetched == next.id) return;
    _prefetched = next.id;
    final url = branding.backgroundUrl(next);
    if (!next.isSvg) unawaited(precacheImage(CachedNetworkImageProvider(url), context, onError: (_, _) {}));
  }
}
