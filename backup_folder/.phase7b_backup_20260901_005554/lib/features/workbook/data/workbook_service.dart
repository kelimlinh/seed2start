import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/routing/app_routes.dart';
import '../../gamification/data/gamification_service.dart';
import 'workbook_models.dart';

abstract final class WorkbookCatalog {
  static const chapters = <WorkbookChapter>[
    WorkbookChapter(
      id: 'chapter_01',
      number: 1,
      order: 1,
      title: LocalizedWorkbookText(
        vi: 'Tôi hiện tại và tương lai',
        en: 'My Present and Future',
      ),
      description: LocalizedWorkbookText(
        vi: 'Khám phá bản thân và hình dung hướng đi mà bạn muốn vun trồng.',
        en: 'Explore who you are and the direction you want to grow toward.',
      ),
    ),
    WorkbookChapter(
      id: 'chapter_02',
      number: 2,
      order: 2,
      title: LocalizedWorkbookText(
        vi: 'Nuôi dưỡng nội lực',
        en: 'Nurturing Inner Strength',
      ),
      description: LocalizedWorkbookText(
        vi: 'Thực hành Hy vọng, Niềm tin vào năng lực, Khả năng phục hồi và Lạc quan.',
        en: 'Practice Hope, Self-efficacy, Resilience, and Optimism.',
      ),
    ),
    WorkbookChapter(
      id: 'chapter_03',
      number: 3,
      order: 3,
      title: LocalizedWorkbookText(
        vi: 'Từ ý tưởng đến hành động',
        en: 'From Ideas to Action',
      ),
      description: LocalizedWorkbookText(
        vi: 'Quan sát vấn đề, phát triển ý tưởng và thử biến điều mình nghĩ thành hành động nhỏ.',
        en: 'Notice problems, develop ideas, and turn your thinking into small actions.',
      ),
    ),
  ];

  static const lessons = <WorkbookLesson>[
    WorkbookLesson(
      id: 'lesson_01',
      number: 1,
      chapterId: 'chapter_01',
      title: LocalizedWorkbookText(
        vi: 'Định vị “tọa độ” cá nhân',
        en: 'Locate Your Personal Coordinates',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Định vị bản thân',
        en: 'Locate Yourself',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Nhìn lại điểm mạnh, điều mình quan tâm và những trải nghiệm đang tạo nên mình.',
        en: 'Notice your strengths, interests, and experiences that are shaping who you are.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Trong sổ tay, bạn đang bắt đầu bằng việc nhìn mình từ nhiều góc độ. Trên website, hãy dùng các hoạt động số như một phần mở rộng chứ không thay thế phần bạn đã viết tay.',
        en: 'In the workbook, you begin by looking at yourself from different angles. Use the digital activities as an extension, not a replacement for what you write by hand.',
      ),
      linkedRoute: AppRoutes.reflection,
      legacyAliases: <String>['self-awareness'],
    ),
    WorkbookLesson(
      id: 'lesson_02',
      number: 2,
      chapterId: 'chapter_01',
      title: LocalizedWorkbookText(
        vi: 'Hạt giống tương lai',
        en: 'Seeds of the Future',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Hạt giống tương lai',
        en: 'Seeds of the Future',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Hình dung điều mình muốn phát triển và chọn một hướng đi đủ gần để bắt đầu.',
        en: 'Imagine what you want to grow and choose a direction close enough to begin.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Không cần biết chính xác tương lai sẽ ra sao. Bài này giúp bạn gieo một vài “hạt giống” về điều mình muốn thử, học và trở thành.',
        en: 'You do not need to know exactly what the future will look like. This lesson helps you plant a few seeds for what you want to try, learn, and become.',
      ),
      linkedRoute: AppRoutes.goals,
    ),
    WorkbookLesson(
      id: 'lesson_03',
      number: 3,
      chapterId: 'chapter_02',
      title: LocalizedWorkbookText(
        vi: 'Khám phá “khối tài sản ngầm” – Vốn tâm lý',
        en: 'Discover Your Hidden Asset – Psychological Capital',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Khám phá vốn tâm lý',
        en: 'Discover Psychological Capital',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Làm quen với bốn nguồn lực Hope, Self-efficacy, Resilience và Optimism như những năng lực có thể rèn luyện.',
        en: 'Meet Hope, Self-efficacy, Resilience, and Optimism as resources that can be developed.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Bài này là bản đồ để bạn nhận ra bốn nguồn lực bên trong. Hãy xem chúng như những điều có thể luyện tập từng chút một, không phải điểm số để đánh giá bản thân.',
        en: 'This lesson is a map of four inner resources. Treat them as things you can practice over time, not scores that define you.',
      ),
      psycapDimensions: <PsycapDimension>[
        PsycapDimension.hope,
        PsycapDimension.selfEfficacy,
        PsycapDimension.resilience,
        PsycapDimension.optimism,
      ],
      linkedRoute: AppRoutes.journey,
      legacyAliases: <String>['psycap-hero'],
    ),
    WorkbookLesson(
      id: 'lesson_04',
      number: 4,
      chapterId: 'chapter_02',
      title: LocalizedWorkbookText(
        vi: 'Hy vọng – Biết mình muốn đi đâu và tìm được con đường để đến đó',
        en: 'Hope – Know Where You Want to Go and Find Paths Forward',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Hy vọng',
        en: 'Hope',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Xác định một mục tiêu có ý nghĩa và thử tìm nhiều con đường để tiến tới mục tiêu đó.',
        en: 'Choose a meaningful goal and explore more than one path toward it.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Trong sổ tay, bạn đang khám phá cách biến mục tiêu thành những con đường có thể thực hiện. Nếu một đường bị chặn, mình vẫn có thể tìm một hướng khác.',
        en: 'In the workbook, you are turning a goal into possible pathways. If one path is blocked, you can still look for another.',
      ),
      psycapDimensions: <PsycapDimension>[PsycapDimension.hope],
      linkedRoute: AppRoutes.goals,
      legacyAliases: <String>['hope'],
    ),
    WorkbookLesson(
      id: 'lesson_05',
      number: 5,
      chapterId: 'chapter_02',
      title: LocalizedWorkbookText(
        vi: 'Niềm tin vào năng lực bản thân – “Mình có thể làm được”',
        en: 'Self-efficacy – “I Can Do This”',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Niềm tin vào năng lực bản thân',
        en: 'Self-efficacy',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Nhận ra bằng chứng từ những việc mình từng học được, làm được và dám thử.',
        en: 'Notice evidence from things you have learned, completed, and dared to try.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Sự tự tin không cần bắt đầu từ cảm giác “mình giỏi”. Nó có thể lớn dần từ những lần bạn thử, học và nhìn thấy bằng chứng rằng mình tiến bộ.',
        en: 'Confidence does not have to begin with feeling “good enough.” It can grow from trying, learning, and noticing evidence of progress.',
      ),
      psycapDimensions: <PsycapDimension>[PsycapDimension.selfEfficacy],
      linkedRoute: AppRoutes.journey,
      legacyAliases: <String>['self-efficacy'],
    ),
    WorkbookLesson(
      id: 'lesson_06',
      number: 6,
      chapterId: 'chapter_02',
      title: LocalizedWorkbookText(
        vi: 'Khả năng phục hồi – Đứng dậy sau những lần vấp ngã',
        en: 'Resilience – Getting Back Up After Setbacks',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Khả năng phục hồi',
        en: 'Resilience',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Học cách nhìn lại điều chưa như ý, điều chỉnh và chọn một bước để quay lại.',
        en: 'Learn to review a setback, adjust, and choose a step to return.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Phục hồi không có nghĩa là phải ổn ngay. Điều quan trọng là bạn biết dừng lại, nhìn lại và tìm một cách phù hợp để tiếp tục.',
        en: 'Resilience does not mean you must feel fine immediately. What matters is pausing, reflecting, and finding a workable way to continue.',
      ),
      psycapDimensions: <PsycapDimension>[PsycapDimension.resilience],
      linkedRoute: AppRoutes.reflection,
      legacyAliases: <String>['resilience'],
    ),
    WorkbookLesson(
      id: 'lesson_07',
      number: 7,
      chapterId: 'chapter_02',
      title: LocalizedWorkbookText(
        vi: 'Sự lạc quan – Nhìn thấy cơ hội trong thử thách',
        en: 'Optimism – Seeing Possibilities in Challenges',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Sự lạc quan',
        en: 'Optimism',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Tập nhìn một tình huống theo hướng cân bằng: nhận ra khó khăn nhưng vẫn thấy điều có thể cải thiện.',
        en: 'Practice a balanced perspective that acknowledges difficulty while noticing what can still improve.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Lạc quan ở đây không phải “mọi chuyện đều tốt”. Bạn đang luyện cách nhìn thực tế nhưng vẫn để lại chỗ cho khả năng tốt hơn.',
        en: 'Optimism here does not mean “everything is fine.” You are practicing a realistic view that still leaves room for improvement.',
      ),
      psycapDimensions: <PsycapDimension>[PsycapDimension.optimism],
      linkedRoute: AppRoutes.reflection,
      legacyAliases: <String>['optimism'],
    ),
    WorkbookLesson(
      id: 'lesson_08',
      number: 8,
      chapterId: 'chapter_02',
      title: LocalizedWorkbookText(
        vi: 'Từ vốn tâm lý đến tư duy khởi nghiệp',
        en: 'From Psychological Capital to Entrepreneurial Thinking',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Từ PsyCap đến tư duy khởi nghiệp',
        en: 'From PsyCap to Entrepreneurial Thinking',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Kết nối nội lực với tinh thần chủ động, dám thử, giải quyết vấn đề và tạo giá trị.',
        en: 'Connect inner resources with initiative, experimentation, problem solving, and value creation.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Bài này nối bốn nguồn lực tâm lý với cách một người chủ động quan sát, thử ý tưởng và hành động trước những vấn đề quanh mình.',
        en: 'This lesson connects the four psychological resources with the way a person notices problems, tests ideas, and takes initiative.',
      ),
      psycapDimensions: <PsycapDimension>[
        PsycapDimension.hope,
        PsycapDimension.selfEfficacy,
        PsycapDimension.resilience,
        PsycapDimension.optimism,
      ],
      linkedRoute: AppRoutes.journey,
      legacyAliases: <String>['entrepreneurial-mindset'],
    ),
    WorkbookLesson(
      id: 'lesson_09',
      number: 9,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Nhìn thấy cơ hội trong những điều quen thuộc',
        en: 'Spot Opportunities in Familiar Things',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Nhìn thấy cơ hội',
        en: 'Spot Opportunities',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Quan sát những bất tiện và nhu cầu quanh mình như điểm bắt đầu của một ý tưởng.',
        en: 'Notice everyday frictions and needs as possible starting points for an idea.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Cơ hội không nhất thiết bắt đầu từ một ý tưởng lớn. Hãy thử nhìn kỹ những điều quen thuộc và hỏi: “Có điều gì có thể tốt hơn không?”',
        en: 'Opportunities do not have to start with a big idea. Look closely at familiar situations and ask, “Could something work better?”',
      ),
    ),
    WorkbookLesson(
      id: 'lesson_10',
      number: 10,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Tư duy sáng tạo – Một vấn đề, nhiều cách giải',
        en: 'Creative Thinking – One Problem, Many Solutions',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Tư duy sáng tạo',
        en: 'Creative Thinking',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Tạo nhiều phương án trước khi vội chọn một đáp án duy nhất.',
        en: 'Generate multiple possibilities before rushing to one answer.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Sáng tạo không chỉ là nghĩ ra thứ chưa ai từng thấy. Đôi khi, đó là thử nhìn cùng một vấn đề từ nhiều góc và kết hợp những điều đã có theo cách mới.',
        en: 'Creativity is not only about inventing something no one has seen. It can mean viewing one problem from different angles and recombining what already exists.',
      ),
    ),
    WorkbookLesson(
      id: 'lesson_11',
      number: 11,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Giải quyết vấn đề – Mỗi khó khăn đều có lối ra',
        en: 'Problem Solving – Finding a Way Forward',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Giải quyết vấn đề',
        en: 'Problem Solving',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Tách một vấn đề thành phần nhỏ hơn, xác định nguyên nhân và chọn bước xử lý phù hợp.',
        en: 'Break a problem into smaller parts, identify causes, and choose a workable next step.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Khi một vấn đề quá lớn, mình dễ bị kẹt. Bài này giúp bạn thu nhỏ vấn đề để nhìn rõ điều nào có thể xử lý trước.',
        en: 'A problem can feel overwhelming when it stays too large. This lesson helps you make it smaller and see what can be addressed first.',
      ),
      linkedRoute: AppRoutes.reflection,
    ),
    WorkbookLesson(
      id: 'lesson_12',
      number: 12,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Biến ý tưởng thành kế hoạch',
        en: 'Turn an Idea into a Plan',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Biến ý tưởng thành kế hoạch',
        en: 'Turn Ideas into Plans',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Chuyển một ý tưởng thành mục tiêu, bước thực hiện và mốc thời gian vừa sức.',
        en: 'Turn an idea into a goal, manageable steps, and a practical timeline.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Một ý tưởng trở nên dễ bắt đầu hơn khi bạn biết bước đầu tiên là gì. Hãy biến điều đang nghĩ thành một kế hoạch đủ nhỏ để thử.',
        en: 'An idea becomes easier to start when you know the first step. Turn what you are thinking into a plan small enough to try.',
      ),
      linkedRoute: AppRoutes.goals,
    ),
    WorkbookLesson(
      id: 'lesson_13',
      number: 13,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Thử nghiệm để học hỏi – Ý tưởng không cần hoàn hảo',
        en: 'Experiment to Learn – Ideas Do Not Need to Be Perfect',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Thử nghiệm để học hỏi',
        en: 'Experiment to Learn',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Thử một phiên bản nhỏ, nhận phản hồi và dùng điều học được để điều chỉnh ý tưởng.',
        en: 'Try a small version, gather feedback, and use what you learn to improve the idea.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Thử nghiệm không phải để chứng minh ý tưởng hoàn hảo. Nó giúp bạn biết điều gì đang đúng, điều gì cần sửa và nên thử gì tiếp theo.',
        en: 'An experiment is not meant to prove an idea is perfect. It helps you learn what works, what needs changing, and what to try next.',
      ),
      linkedRoute: AppRoutes.reflection,
    ),
    WorkbookLesson(
      id: 'lesson_14',
      number: 14,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Ý tưởng tạo ra giá trị như thế nào?',
        en: 'How Does an Idea Create Value?',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Ý tưởng tạo ra giá trị',
        en: 'Creating Value',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Nhìn lại ý tưởng từ góc độ người nhận giá trị: ai được giúp, được cải thiện hoặc được thuận tiện hơn?',
        en: 'Review an idea from the perspective of the person receiving value: who is helped, improved, or made better off?',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Một ý tưởng chỉ thật sự có ý nghĩa khi nó tạo ra giá trị cho ai đó. Hãy thử nhìn ý tưởng của bạn từ góc nhìn của người sẽ sử dụng hoặc hưởng lợi.',
        en: 'An idea becomes meaningful when it creates value for someone. Look at your idea from the perspective of the person who may use or benefit from it.',
      ),
    ),
  ];

  static WorkbookChapter? chapterById(String id) {
    for (final chapter in chapters) {
      if (chapter.id == id) return chapter;
    }
    return null;
  }

  static WorkbookLesson? byId(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id || lesson.legacyAliases.contains(id)) return lesson;
    }
    return null;
  }

  static String? canonicalLessonId(String id) => byId(id)?.id;

  static List<WorkbookLesson> lessonsForChapter(String chapterId) {
    return lessons
        .where((lesson) => lesson.chapterId == chapterId)
        .toList(growable: false);
  }

  static WorkbookLesson? firstIncomplete(Set<String> completedIds) {
    for (final lesson in lessons) {
      if (!completedIds.contains(lesson.id)) return lesson;
    }
    return null;
  }

  static int completedCountForChapter(
    String chapterId,
    Set<String> completedIds,
  ) {
    return lessonsForChapter(chapterId)
        .where((lesson) => completedIds.contains(lesson.id))
        .length;
  }
}

class WorkbookService {
  WorkbookService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GamificationService? gamificationService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _gamificationService = gamificationService ??
        GamificationService(auth: _auth, firestore: _firestore);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  late final GamificationService _gamificationService;

  Stream<Set<String>> watchCompletedLessonIds() {
    return _progressCollection.snapshots().map((snapshot) {
      final canonicalStates = <String, bool>{};
      final completedFromLegacy = <String>{};

      for (final doc in snapshot.docs) {
        final lesson = WorkbookCatalog.byId(doc.id);
        if (lesson == null) continue;

        final completed = doc.data()['completed'] == true;
        if (doc.id == lesson.id) {
          canonicalStates[lesson.id] = completed;
        } else if (completed) {
          completedFromLegacy.add(lesson.id);
        }
      }

      final completedIds = <String>{};
      for (final lesson in WorkbookCatalog.lessons) {
        final canonicalState = canonicalStates[lesson.id];
        if (canonicalState == true ||
            (canonicalState == null &&
                completedFromLegacy.contains(lesson.id))) {
          completedIds.add(lesson.id);
        }
      }
      return completedIds;
    });
  }

  Stream<bool> watchLessonCompleted(String lessonId) {
    final canonical = WorkbookCatalog.canonicalLessonId(lessonId) ?? lessonId;
    return watchCompletedLessonIds().map((ids) => ids.contains(canonical));
  }

  Stream<List<WorkbookResource>> watchPublishedResourcesForLesson(
    String lessonId,
  ) {
    final canonical = WorkbookCatalog.canonicalLessonId(lessonId) ?? lessonId;
    return _firestore
        .collection('resources')
        .where('lessonId', isEqualTo: canonical)
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final resources = snapshot.docs
          .map(
            (doc) => WorkbookResource.fromFirestore(
              doc.id,
              doc.data(),
            ),
          )
          .toList();
      resources.sort((a, b) => a.order.compareTo(b.order));
      return resources;
    });
  }

  Future<void> setLessonCompleted({
    required String lessonId,
    required bool completed,
  }) async {
    final lesson = WorkbookCatalog.byId(lessonId);
    if (lesson == null) {
      throw ArgumentError.value(lessonId, 'lessonId', 'Unknown workbook lesson.');
    }

    final now = FieldValue.serverTimestamp();
    await _progressCollection.doc(lesson.id).set({
      'lessonId': lesson.id,
      'chapterId': lesson.chapterId,
      'completed': completed,
      'completedAt': completed ? now : null,
      'lastOpenedAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    if (completed) {
      await _gamificationService.awardWorkbookLesson(lesson.id);
    }
  }

  CollectionReference<Map<String, dynamic>> get _progressCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Workbook progress requires an authenticated user.');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workbookProgress');
  }
}
