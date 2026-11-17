enum AiLaunchSource {
  general,
  workbookReflection,
}

class AiLaunchContext {
  const AiLaunchContext({
    this.source = AiLaunchSource.general,
    this.chapterId,
    this.lessonId,
    this.resourceId,
    this.blockId,
    this.psycapDimensionIds = const <String>[],
    this.aiFocus,
    this.aiGuidance,
    this.reflectionPrompt,
    this.reflectionDraft,
  });

  static const int maxReflectionDraftChars = 1600;

  final AiLaunchSource source;
  final String? chapterId;
  final String? lessonId;
  final String? resourceId;
  final String? blockId;
  final List<String> psycapDimensionIds;
  final String? aiFocus;
  final String? aiGuidance;
  final String? reflectionPrompt;

  /// A draft is included only when the student explicitly taps “Hỏi Mầm”
  /// from that reflection. It is not loaded from reflection history.
  final String? reflectionDraft;

  bool get isContextual => source != AiLaunchSource.general;

  /// General Mầm chat keeps the legacy `main` thread.
  ///
  /// Workbook reflection launches get a separate thread so unrelated general
  /// chat history cannot pull the model away from the current activity.
  String get conversationId {
    if (source != AiLaunchSource.workbookReflection) return 'main';

    final resource = _safeThreadPart(resourceId);
    final block = _safeThreadPart(blockId);
    return 'workbook_${resource}_$block';
  }

  Map<String, Object> toRequestMap() {
    final result = <String, Object>{
      'source': _sourceId(source),
    };

    _putIfNotBlank(result, 'chapterId', chapterId);
    _putIfNotBlank(result, 'lessonId', lessonId);
    _putIfNotBlank(result, 'resourceId', resourceId);
    _putIfNotBlank(result, 'blockId', blockId);

    final dimensions = psycapDimensionIds
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .take(4)
        .toList(growable: false);
    if (dimensions.isNotEmpty) {
      result['psycapDimensions'] = dimensions;
    }

    _putIfNotBlank(result, 'aiFocus', aiFocus, maxChars: 160);
    _putIfNotBlank(result, 'aiGuidance', aiGuidance, maxChars: 700);
    _putIfNotBlank(result, 'reflectionPrompt', reflectionPrompt, maxChars: 700);
    _putIfNotBlank(
      result,
      'reflectionDraft',
      reflectionDraft,
      maxChars: maxReflectionDraftChars,
    );

    return result;
  }

  String get debugSummary {
    final draftLength = reflectionDraft?.trim().length ?? 0;
    return 'source=${_sourceId(source)} '
        'chapter=${chapterId ?? '-'} '
        'lesson=${lessonId ?? '-'} '
        'resource=${resourceId ?? '-'} '
        'block=${blockId ?? '-'} '
        'dimensions=${psycapDimensionIds.join(',')} '
        'thread=$conversationId '
        'draftChars=$draftLength';
  }

  static void _putIfNotBlank(
    Map<String, Object> target,
    String key,
    String? rawValue, {
    int? maxChars,
  }) {
    var value = rawValue?.trim();
    if (value == null || value.isEmpty) return;

    if (maxChars != null && value.length > maxChars) {
      value = value.substring(0, maxChars);
    }
    target[key] = value;
  }
}

String _safeThreadPart(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return 'context';

  final cleaned = value.replaceAll(
    RegExp(r'[^A-Za-z0-9_-]'),
    '_',
  );

  return cleaned.length <= 70 ? cleaned : cleaned.substring(0, 70);
}

String _sourceId(AiLaunchSource source) {
  return switch (source) {
    AiLaunchSource.general => 'general',
    AiLaunchSource.workbookReflection => 'workbookReflection',
  };
}
