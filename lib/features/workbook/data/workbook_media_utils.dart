String? extractYouTubeVideoId({
  String? youtubeId,
  String? mediaUrl,
}) {
  final direct = youtubeId?.trim();
  if (direct != null && _isYouTubeId(direct)) {
    return direct;
  }

  final rawUrl = mediaUrl?.trim();
  if (rawUrl == null || rawUrl.isEmpty) return null;

  final uri = Uri.tryParse(rawUrl);
  if (uri == null || !uri.hasScheme) return null;

  final host = uri.host.toLowerCase();
  String? candidate;

  if (host == 'youtu.be' || host.endsWith('.youtu.be')) {
    candidate = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  } else if (host == 'youtube.com' ||
      host.endsWith('.youtube.com') ||
      host == 'youtube-nocookie.com' ||
      host.endsWith('.youtube-nocookie.com')) {
    if (uri.path == '/watch') {
      candidate = uri.queryParameters['v'];
    } else if (uri.pathSegments.length >= 2 &&
        const {'embed', 'shorts', 'live'}.contains(uri.pathSegments.first)) {
      candidate = uri.pathSegments[1];
    }
  }

  final normalized = candidate?.trim();
  return normalized != null && _isYouTubeId(normalized) ? normalized : null;
}

Uri? parseSafeHttpsMediaUri(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme.toLowerCase() != 'https' || uri.host.isEmpty) {
    return null;
  }
  return uri;
}

bool _isYouTubeId(String value) {
  return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value);
}
