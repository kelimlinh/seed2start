import 'package:flutter_test/flutter_test.dart';
import 'package:psycapnote_website/features/workbook/data/workbook_models.dart';

void main() {
  test('Resource block parser supports the scenario flow', () {
    final simulation = WorkbookResourceBlock.fromFirestore(
      '01_simulation',
      <String, dynamic>{
        'type': 'simulation',
        'order': 1,
        'enabled': true,
        'title': <String, String>{'vi': 'Tình huống giả lập'},
        'body': <String, String>{'vi': 'Một tình huống do nhóm biên soạn.'},
      },
    );
    final response = WorkbookResourceBlock.fromFirestore(
      '02_response',
      <String, dynamic>{
        'type': 'optionalResponse',
        'order': 2,
        'enabled': true,
        'prompt': <String, String>{'vi': 'Nếu là bạn, bạn sẽ làm gì?'},
      },
    );
    final realCase = WorkbookResourceBlock.fromFirestore(
      '03_real_case',
      <String, dynamic>{
        'type': 'realCase',
        'order': 3,
        'enabled': true,
        'body': <String, String>{'vi': 'Câu chuyện thực tế.'},
        'source': <String, String>{
          'title': 'Nguồn tham khảo',
          'url': 'https://example.com',
        },
      },
    );
    final takeaway = WorkbookResourceBlock.fromFirestore(
      '04_takeaway',
      <String, dynamic>{
        'type': 'lessonTakeaway',
        'order': 4,
        'enabled': true,
        'body': <String, String>{'vi': 'Bài học do nhóm tự điền.'},
      },
    );

    expect(simulation.type, WorkbookResourceBlockType.simulation);
    expect(response.type, WorkbookResourceBlockType.optionalResponse);
    expect(realCase.type, WorkbookResourceBlockType.realCase);
    expect(realCase.sourceTitle, 'Nguồn tham khảo');
    expect(takeaway.type, WorkbookResourceBlockType.takeaway);
  });

  test('Localized block content falls back to Vietnamese', () {
    const text = LocalizedWorkbookText(vi: 'Nội dung tiếng Việt');
    expect(text.resolve('en'), 'Nội dung tiếng Việt');
  });
}
