import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psycapnote_website/core/localization/app_localizations_en.dart';
import 'package:psycapnote_website/core/localization/app_localizations_vi.dart';
import 'package:psycapnote_website/features/workbook/data/workbook_service.dart';

void main() {
  test('Localization hỗ trợ Tiếng Việt và English', () {
    const vi = AppLocalizationsVi(Locale('vi'));
    const en = AppLocalizationsEn(Locale('en'));

    expect(vi.login, 'Đăng nhập');
    expect(vi.register, 'Tạo tài khoản');
    expect(en.login, 'Sign in');
    expect(en.register, 'Create account');
    expect(vi.aiCoach, 'Mầm');
    expect(en.aiCoach, 'Mầm');
  });

  test('Workbook sử dụng đúng 3 chương và 14 bài', () {
    expect(WorkbookCatalog.chapters.length, 3);
    expect(WorkbookCatalog.lessons.length, 14);
    expect(WorkbookCatalog.lessonsForChapter('chapter_01').length, 2);
    expect(WorkbookCatalog.lessonsForChapter('chapter_02').length, 6);
    expect(WorkbookCatalog.lessonsForChapter('chapter_03').length, 6);
  });

  test('Legacy lesson an toàn được map sang lesson canonical', () {
    expect(WorkbookCatalog.byId('hope')?.id, 'lesson_04');
    expect(WorkbookCatalog.byId('self-efficacy')?.id, 'lesson_05');
    expect(WorkbookCatalog.byId('resilience')?.id, 'lesson_06');
    expect(WorkbookCatalog.byId('optimism')?.id, 'lesson_07');

    // Không tự map các bài legacy mơ hồ sang curriculum mới.
    expect(WorkbookCatalog.byId('design-thinking'), isNull);
    expect(WorkbookCatalog.byId('mvp'), isNull);
  });
}
