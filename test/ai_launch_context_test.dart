import 'package:flutter_test/flutter_test.dart';
import 'package:psycapnote_website/features/ai/data/ai_launch_context.dart';

void main() {
  test('general Mầm chat keeps the legacy main conversation', () {
    const context = AiLaunchContext();

    expect(context.conversationId, 'main');
    expect(context.isContextual, isFalse);
  });

  test('workbook reflection gets a stable isolated conversation', () {
    const context = AiLaunchContext(
      source: AiLaunchSource.workbookReflection,
      resourceId: 'B06',
      blockId: '06_reflection',
    );

    expect(
      context.conversationId,
      'workbook_B06_06_reflection',
    );
  });

  test('conversation id sanitizes unsafe path characters', () {
    const context = AiLaunchContext(
      source: AiLaunchSource.workbookReflection,
      resourceId: 'SC/B06 01',
      blockId: '06/reflection',
    );

    expect(
      context.conversationId,
      'workbook_SC_B06_01_06_reflection',
    );
  });

  test('workbook context keeps only selected activity data', () {
    final context = AiLaunchContext(
      source: AiLaunchSource.workbookReflection,
      chapterId: 'chapter_02',
      lessonId: 'lesson_06',
      resourceId: 'B06',
      blockId: '06_reflection',
      psycapDimensionIds: const <String>['resilience'],
      aiFocus: 'resilience_recovery',
      aiGuidance: 'Gợi mở, không viết đáp án thay học sinh.',
      reflectionPrompt: 'Bạn học được gì từ tình huống này?',
      reflectionDraft: 'Mình nghĩ lần sau mình sẽ thử lại theo cách khác.',
    );

    final payload = context.toRequestMap();

    expect(payload['source'], 'workbookReflection');
    expect(payload['lessonId'], 'lesson_06');
    expect(payload['resourceId'], 'B06');
    expect(payload['blockId'], '06_reflection');
    expect(payload['psycapDimensions'], const <String>['resilience']);
    expect(payload.containsKey('email'), isFalse);
    expect(payload.containsKey('moodHistory'), isFalse);
    expect(payload.containsKey('reflectionHistory'), isFalse);
  });

  test('reflection draft is capped before backend transport', () {
    final context = AiLaunchContext(
      source: AiLaunchSource.workbookReflection,
      reflectionDraft: 'x' * 5000,
    );

    final payload = context.toRequestMap();
    final draft = payload['reflectionDraft']! as String;

    expect(draft.length, AiLaunchContext.maxReflectionDraftChars);
  });
}
