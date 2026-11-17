import 'package:flutter_test/flutter_test.dart';
import 'package:psycapnote_website/features/workbook/data/workbook_media_utils.dart';

void main() {
  group('extractYouTubeVideoId', () {
    test('accepts a direct 11-character id', () {
      expect(
        extractYouTubeVideoId(youtubeId: 'dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
    });

    test('extracts ids from common YouTube URLs', () {
      expect(
        extractYouTubeVideoId(
          mediaUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        extractYouTubeVideoId(
          mediaUrl: 'https://youtu.be/dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        extractYouTubeVideoId(
          mediaUrl: 'https://www.youtube.com/shorts/dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
    });

    test('rejects invalid ids and unrelated hosts', () {
      expect(extractYouTubeVideoId(youtubeId: 'not-an-id'), isNull);
      expect(
        extractYouTubeVideoId(
          mediaUrl: 'https://example.com/watch?v=dQw4w9WgXcQ',
        ),
        isNull,
      );
    });
  });

  group('parseSafeHttpsMediaUri', () {
    test('accepts https and rejects unsafe/non-web URLs', () {
      expect(
        parseSafeHttpsMediaUri('https://example.com/media.mp4')?.scheme,
        'https',
      );
      expect(parseSafeHttpsMediaUri('http://example.com/media.mp4'), isNull);
      expect(parseSafeHttpsMediaUri('javascript:alert(1)'), isNull);
      expect(parseSafeHttpsMediaUri(''), isNull);
    });
  });
}
