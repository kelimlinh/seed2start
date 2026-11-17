import 'package:flutter_test/flutter_test.dart';
import 'package:psycapnote_website/features/ai/data/ai_launch_context.dart';

void main() {
  test('workbook context keeps only the selected activity data', () {
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

  test('reflection draft is capped before future backend transport', () {
    final context = AiLaunchContext(
      source: AiLaunchSource.workbookReflection,
      reflectionDraft: 'x' * 5000,
    );

    final payload = context.toRequestMap();
    final draft = payload['reflectionDraft']! as String;

    expect(draft.length, AiLaunchContext.maxReflectionDraftChars);
  });
}
