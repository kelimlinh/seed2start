enum PsycapDimension {
  hope,
  selfEfficacy,
  resilience,
  optimism,
}

enum WorkbookResourceType {
  scenario,
  podcast,
  youtube,
  video,
  activity,
  reflection,
  challenge,
  caseStudy,
  comic,
  interview,
  quiz,
}

enum WorkbookResourceBlockType {
  text,
  simulation,
  optionalResponse,
  realCase,
  youtube,
  takeaway,
  reflection,
  image,
  podcast,
  video,
}

class LocalizedWorkbookText {
  const LocalizedWorkbookText({
    required this.vi,
    this.en = '',
  });

  final String vi;
  final String en;

  String resolve(String languageCode) {
    if (languageCode == 'en' && en.trim().isNotEmpty) return en;
    return vi;
  }

  bool get isEmpty => vi.trim().isEmpty && en.trim().isEmpty;

  factory LocalizedWorkbookText.fromMap(Object? raw) {
    if (raw is String) {
      return LocalizedWorkbookText(vi: raw);
    }
    if (raw is! Map) {
      return const LocalizedWorkbookText(vi: '');
    }

    return LocalizedWorkbookText(
      vi: raw['vi'] is String ? raw['vi'] as String : '',
      en: raw['en'] is String ? raw['en'] as String : '',
    );
  }
}

class WorkbookChapter {
  const WorkbookChapter({
    required this.id,
    required this.number,
    required this.order,
    required this.title,
    required this.description,
    this.published = true,
  });

  final String id;
  final int number;
  final int order;
  final LocalizedWorkbookText title;
  final LocalizedWorkbookText description;
  final bool published;
}

class WorkbookLesson {
  const WorkbookLesson({
    required this.id,
    required this.number,
    required this.chapterId,
    required this.title,
    required this.shortTitle,
    required this.objective,
    required this.intro,
    this.psycapDimensions = const <PsycapDimension>[],
    this.linkedRoute,
    this.legacyAliases = const <String>[],
    this.published = true,
  });

  final String id;
  final int number;
  final String chapterId;
  final LocalizedWorkbookText title;
  final LocalizedWorkbookText shortTitle;
  final LocalizedWorkbookText objective;
  final LocalizedWorkbookText intro;
  final List<PsycapDimension> psycapDimensions;
  final String? linkedRoute;
  final List<String> legacyAliases;
  final bool published;
}

class WorkbookResource {
  const WorkbookResource({
    required this.resourceId,
    required this.chapterId,
    required this.lessonId,
    required this.type,
    required this.title,
    required this.description,
    required this.order,
    this.psycapDimensions = const <PsycapDimension>[],
    this.accessCode,
    this.durationMinutes,
    this.xpReward = 0,
    this.aiFocus,
    this.aiGuidance,
    this.published = false,
  });

  final String resourceId;
  final String chapterId;
  final String lessonId;
  final WorkbookResourceType type;
  final LocalizedWorkbookText title;
  final LocalizedWorkbookText description;
  final int order;
  final List<PsycapDimension> psycapDimensions;
  final String? accessCode;
  final int? durationMinutes;
  final int xpReward;
  final String? aiFocus;
  final String? aiGuidance;
  final bool published;

  factory WorkbookResource.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final rawDimensions = data['psycapDimensions'];
    final dimensions = rawDimensions is List
        ? rawDimensions
            .whereType<String>()
            .map(psycapDimensionFromId)
            .whereType<PsycapDimension>()
            .toList(growable: false)
        : const <PsycapDimension>[];

    return WorkbookResource(
      resourceId: documentId,
      chapterId: data['chapterId'] is String ? data['chapterId'] as String : '',
      lessonId: data['lessonId'] is String ? data['lessonId'] as String : '',
      type: workbookResourceTypeFromId(
        data['type'] is String ? data['type'] as String : '',
      ),
      title: LocalizedWorkbookText.fromMap(data['title']),
      description: LocalizedWorkbookText.fromMap(data['description']),
      order: data['order'] is num ? (data['order'] as num).toInt() : 0,
      psycapDimensions: dimensions,
      accessCode:
          data['accessCode'] is String ? data['accessCode'] as String : null,
      durationMinutes: data['durationMinutes'] is num
          ? (data['durationMinutes'] as num).toInt()
          : null,
      xpReward: data['xpReward'] is num ? (data['xpReward'] as num).toInt() : 0,
      aiFocus: _readAiField(data['aiContext'], 'focus'),
      aiGuidance: _readAiField(data['aiContext'], 'guidance'),
      published: data['published'] == true,
    );
  }

  static String? _readAiField(Object? raw, String field) {
    if (raw is! Map) return null;
    final value = raw[field];
    return value is String && value.trim().isNotEmpty ? value : null;
  }
}

class WorkbookResourceBlock {
  const WorkbookResourceBlock({
    required this.blockId,
    required this.type,
    required this.order,
    required this.title,
    required this.body,
    required this.prompt,
    required this.placeholder,
    this.enabled = true,
    this.aiEnabled = false,
    this.youtubeId,
    this.mediaUrl,
    this.sourceTitle,
    this.sourceUrl,
  });

  final String blockId;
  final WorkbookResourceBlockType type;
  final int order;
  final LocalizedWorkbookText title;
  final LocalizedWorkbookText body;
  final LocalizedWorkbookText prompt;
  final LocalizedWorkbookText placeholder;
  final bool enabled;
  final bool aiEnabled;
  final String? youtubeId;
  final String? mediaUrl;
  final String? sourceTitle;
  final String? sourceUrl;

  factory WorkbookResourceBlock.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final source = data['source'];
    return WorkbookResourceBlock(
      blockId: documentId,
      type: workbookResourceBlockTypeFromId(
        data['type'] is String ? data['type'] as String : '',
      ),
      order: data['order'] is num ? (data['order'] as num).toInt() : 0,
      title: LocalizedWorkbookText.fromMap(data['title']),
      body: LocalizedWorkbookText.fromMap(data['body']),
      prompt: LocalizedWorkbookText.fromMap(data['prompt']),
      placeholder: LocalizedWorkbookText.fromMap(data['placeholder']),
      enabled: data['enabled'] != false,
      aiEnabled: data['aiEnabled'] == true,
      youtubeId:
          data['youtubeId'] is String ? data['youtubeId'] as String : null,
      mediaUrl: data['mediaUrl'] is String ? data['mediaUrl'] as String : null,
      sourceTitle: source is Map && source['title'] is String
          ? source['title'] as String
          : null,
      sourceUrl: source is Map && source['url'] is String
          ? source['url'] as String
          : null,
    );
  }
}

PsycapDimension? psycapDimensionFromId(String id) {
  return switch (id) {
    'hope' => PsycapDimension.hope,
    'selfEfficacy' => PsycapDimension.selfEfficacy,
    'resilience' => PsycapDimension.resilience,
    'optimism' => PsycapDimension.optimism,
    _ => null,
  };
}

WorkbookResourceType workbookResourceTypeFromId(String id) {
  return switch (id) {
    'scenario' => WorkbookResourceType.scenario,
    'podcast' => WorkbookResourceType.podcast,
    'youtube' => WorkbookResourceType.youtube,
    'video' => WorkbookResourceType.video,
    'activity' => WorkbookResourceType.activity,
    'reflection' => WorkbookResourceType.reflection,
    'challenge' => WorkbookResourceType.challenge,
    'caseStudy' => WorkbookResourceType.caseStudy,
    'comic' => WorkbookResourceType.comic,
    'interview' => WorkbookResourceType.interview,
    'quiz' => WorkbookResourceType.quiz,
    _ => WorkbookResourceType.activity,
  };
}

WorkbookResourceBlockType workbookResourceBlockTypeFromId(String id) {
  return switch (id) {
    'simulation' => WorkbookResourceBlockType.simulation,
    'optionalResponse' => WorkbookResourceBlockType.optionalResponse,
    'realCase' => WorkbookResourceBlockType.realCase,
    'youtube' => WorkbookResourceBlockType.youtube,
    'takeaway' || 'lessonTakeaway' => WorkbookResourceBlockType.takeaway,
    'reflection' => WorkbookResourceBlockType.reflection,
    'image' => WorkbookResourceBlockType.image,
    'podcast' => WorkbookResourceBlockType.podcast,
    'video' => WorkbookResourceBlockType.video,
    _ => WorkbookResourceBlockType.text,
  };
}
