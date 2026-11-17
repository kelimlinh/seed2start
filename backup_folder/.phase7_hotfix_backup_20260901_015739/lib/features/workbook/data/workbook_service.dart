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
        vi: 'TÃ´i hiá»‡n táº¡i vÃ  tÆ°Æ¡ng lai',
        en: 'My Present and Future',
      ),
      description: LocalizedWorkbookText(
        vi: 'KhÃ¡m phÃ¡ báº£n thÃ¢n vÃ  hÃ¬nh dung hÆ°á»›ng Ä‘i mÃ  báº¡n muá»‘n vun trá»“ng.',
        en: 'Explore who you are and the direction you want to grow toward.',
      ),
    ),
    WorkbookChapter(
      id: 'chapter_02',
      number: 2,
      order: 2,
      title: LocalizedWorkbookText(
        vi: 'NuÃ´i dÆ°á»¡ng ná»™i lá»±c',
        en: 'Nurturing Inner Strength',
      ),
      description: LocalizedWorkbookText(
        vi: 'Thá»±c hÃ nh Hy vá»ng, Niá»m tin vÃ o nÄƒng lá»±c, Kháº£ nÄƒng phá»¥c há»“i vÃ  Láº¡c quan.',
        en: 'Practice Hope, Self-efficacy, Resilience, and Optimism.',
      ),
    ),
    WorkbookChapter(
      id: 'chapter_03',
      number: 3,
      order: 3,
      title: LocalizedWorkbookText(
        vi: 'Tá»« Ã½ tÆ°á»Ÿng Ä‘áº¿n hÃ nh Ä‘á»™ng',
        en: 'From Ideas to Action',
      ),
      description: LocalizedWorkbookText(
        vi: 'Quan sÃ¡t váº¥n Ä‘á», phÃ¡t triá»ƒn Ã½ tÆ°á»Ÿng vÃ  thá»­ biáº¿n Ä‘iá»u mÃ¬nh nghÄ© thÃ nh hÃ nh Ä‘á»™ng nhá».',
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
        vi: 'Äá»‹nh vá»‹ â€œtá»a Ä‘á»™â€ cÃ¡ nhÃ¢n',
        en: 'Locate Your Personal Coordinates',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Äá»‹nh vá»‹ báº£n thÃ¢n',
        en: 'Locate Yourself',
      ),
      objective: LocalizedWorkbookText(
        vi: 'NhÃ¬n láº¡i Ä‘iá»ƒm máº¡nh, Ä‘iá»u mÃ¬nh quan tÃ¢m vÃ  nhá»¯ng tráº£i nghiá»‡m Ä‘ang táº¡o nÃªn mÃ¬nh.',
        en: 'Notice your strengths, interests, and experiences that are shaping who you are.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Trong sá»• tay, báº¡n Ä‘ang báº¯t Ä‘áº§u báº±ng viá»‡c nhÃ¬n mÃ¬nh tá»« nhiá»u gÃ³c Ä‘á»™. TrÃªn website, hÃ£y dÃ¹ng cÃ¡c hoáº¡t Ä‘á»™ng sá»‘ nhÆ° má»™t pháº§n má»Ÿ rá»™ng chá»© khÃ´ng thay tháº¿ pháº§n báº¡n Ä‘Ã£ viáº¿t tay.',
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
        vi: 'Háº¡t giá»‘ng tÆ°Æ¡ng lai',
        en: 'Seeds of the Future',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Háº¡t giá»‘ng tÆ°Æ¡ng lai',
        en: 'Seeds of the Future',
      ),
      objective: LocalizedWorkbookText(
        vi: 'HÃ¬nh dung Ä‘iá»u mÃ¬nh muá»‘n phÃ¡t triá»ƒn vÃ  chá»n má»™t hÆ°á»›ng Ä‘i Ä‘á»§ gáº§n Ä‘á»ƒ báº¯t Ä‘áº§u.',
        en: 'Imagine what you want to grow and choose a direction close enough to begin.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'KhÃ´ng cáº§n biáº¿t chÃ­nh xÃ¡c tÆ°Æ¡ng lai sáº½ ra sao. BÃ i nÃ y giÃºp báº¡n gieo má»™t vÃ i â€œháº¡t giá»‘ngâ€ vá» Ä‘iá»u mÃ¬nh muá»‘n thá»­, há»c vÃ  trá»Ÿ thÃ nh.',
        en: 'You do not need to know exactly what the future will look like. This lesson helps you plant a few seeds for what you want to try, learn, and become.',
      ),
      linkedRoute: AppRoutes.goals,
    ),
    WorkbookLesson(
      id: 'lesson_03',
      number: 3,
      chapterId: 'chapter_02',
      title: LocalizedWorkbookText(
        vi: 'KhÃ¡m phÃ¡ â€œkhá»‘i tÃ i sáº£n ngáº§mâ€ â€“ Vá»‘n tÃ¢m lÃ½',
        en: 'Discover Your Hidden Asset â€“ Psychological Capital',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'KhÃ¡m phÃ¡ vá»‘n tÃ¢m lÃ½',
        en: 'Discover Psychological Capital',
      ),
      objective: LocalizedWorkbookText(
        vi: 'LÃ m quen vá»›i bá»‘n nguá»“n lá»±c Hope, Self-efficacy, Resilience vÃ  Optimism nhÆ° nhá»¯ng nÄƒng lá»±c cÃ³ thá»ƒ rÃ¨n luyá»‡n.',
        en: 'Meet Hope, Self-efficacy, Resilience, and Optimism as resources that can be developed.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'BÃ i nÃ y lÃ  báº£n Ä‘á»“ Ä‘á»ƒ báº¡n nháº­n ra bá»‘n nguá»“n lá»±c bÃªn trong. HÃ£y xem chÃºng nhÆ° nhá»¯ng Ä‘iá»u cÃ³ thá»ƒ luyá»‡n táº­p tá»«ng chÃºt má»™t, khÃ´ng pháº£i Ä‘iá»ƒm sá»‘ Ä‘á»ƒ Ä‘Ã¡nh giÃ¡ báº£n thÃ¢n.',
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
        vi: 'Hy vá»ng â€“ Biáº¿t mÃ¬nh muá»‘n Ä‘i Ä‘Ã¢u vÃ  tÃ¬m Ä‘Æ°á»£c con Ä‘Æ°á»ng Ä‘á»ƒ Ä‘áº¿n Ä‘Ã³',
        en: 'Hope â€“ Know Where You Want to Go and Find Paths Forward',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Hy vá»ng',
        en: 'Hope',
      ),
      objective: LocalizedWorkbookText(
        vi: 'XÃ¡c Ä‘á»‹nh má»™t má»¥c tiÃªu cÃ³ Ã½ nghÄ©a vÃ  thá»­ tÃ¬m nhiá»u con Ä‘Æ°á»ng Ä‘á»ƒ tiáº¿n tá»›i má»¥c tiÃªu Ä‘Ã³.',
        en: 'Choose a meaningful goal and explore more than one path toward it.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Trong sá»• tay, báº¡n Ä‘ang khÃ¡m phÃ¡ cÃ¡ch biáº¿n má»¥c tiÃªu thÃ nh nhá»¯ng con Ä‘Æ°á»ng cÃ³ thá»ƒ thá»±c hiá»‡n. Náº¿u má»™t Ä‘Æ°á»ng bá»‹ cháº·n, mÃ¬nh váº«n cÃ³ thá»ƒ tÃ¬m má»™t hÆ°á»›ng khÃ¡c.',
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
        vi: 'Niá»m tin vÃ o nÄƒng lá»±c báº£n thÃ¢n â€“ â€œMÃ¬nh cÃ³ thá»ƒ lÃ m Ä‘Æ°á»£câ€',
        en: 'Self-efficacy â€“ â€œI Can Do Thisâ€',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Niá»m tin vÃ o nÄƒng lá»±c báº£n thÃ¢n',
        en: 'Self-efficacy',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Nháº­n ra báº±ng chá»©ng tá»« nhá»¯ng viá»‡c mÃ¬nh tá»«ng há»c Ä‘Æ°á»£c, lÃ m Ä‘Æ°á»£c vÃ  dÃ¡m thá»­.',
        en: 'Notice evidence from things you have learned, completed, and dared to try.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Sá»± tá»± tin khÃ´ng cáº§n báº¯t Ä‘áº§u tá»« cáº£m giÃ¡c â€œmÃ¬nh giá»iâ€. NÃ³ cÃ³ thá»ƒ lá»›n dáº§n tá»« nhá»¯ng láº§n báº¡n thá»­, há»c vÃ  nhÃ¬n tháº¥y báº±ng chá»©ng ráº±ng mÃ¬nh tiáº¿n bá»™.',
        en: 'Confidence does not have to begin with feeling â€œgood enough.â€ It can grow from trying, learning, and noticing evidence of progress.',
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
        vi: 'Kháº£ nÄƒng phá»¥c há»“i â€“ Äá»©ng dáº­y sau nhá»¯ng láº§n váº¥p ngÃ£',
        en: 'Resilience â€“ Getting Back Up After Setbacks',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Kháº£ nÄƒng phá»¥c há»“i',
        en: 'Resilience',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Há»c cÃ¡ch nhÃ¬n láº¡i Ä‘iá»u chÆ°a nhÆ° Ã½, Ä‘iá»u chá»‰nh vÃ  chá»n má»™t bÆ°á»›c Ä‘á»ƒ quay láº¡i.',
        en: 'Learn to review a setback, adjust, and choose a step to return.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Phá»¥c há»“i khÃ´ng cÃ³ nghÄ©a lÃ  pháº£i á»•n ngay. Äiá»u quan trá»ng lÃ  báº¡n biáº¿t dá»«ng láº¡i, nhÃ¬n láº¡i vÃ  tÃ¬m má»™t cÃ¡ch phÃ¹ há»£p Ä‘á»ƒ tiáº¿p tá»¥c.',
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
        vi: 'Sá»± láº¡c quan â€“ NhÃ¬n tháº¥y cÆ¡ há»™i trong thá»­ thÃ¡ch',
        en: 'Optimism â€“ Seeing Possibilities in Challenges',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Sá»± láº¡c quan',
        en: 'Optimism',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Táº­p nhÃ¬n má»™t tÃ¬nh huá»‘ng theo hÆ°á»›ng cÃ¢n báº±ng: nháº­n ra khÃ³ khÄƒn nhÆ°ng váº«n tháº¥y Ä‘iá»u cÃ³ thá»ƒ cáº£i thiá»‡n.',
        en: 'Practice a balanced perspective that acknowledges difficulty while noticing what can still improve.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Láº¡c quan á»Ÿ Ä‘Ã¢y khÃ´ng pháº£i â€œmá»i chuyá»‡n Ä‘á»u tá»‘tâ€. Báº¡n Ä‘ang luyá»‡n cÃ¡ch nhÃ¬n thá»±c táº¿ nhÆ°ng váº«n Ä‘á»ƒ láº¡i chá»— cho kháº£ nÄƒng tá»‘t hÆ¡n.',
        en: 'Optimism here does not mean â€œeverything is fine.â€ You are practicing a realistic view that still leaves room for improvement.',
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
        vi: 'Tá»« vá»‘n tÃ¢m lÃ½ Ä‘áº¿n tÆ° duy khá»Ÿi nghiá»‡p',
        en: 'From Psychological Capital to Entrepreneurial Thinking',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Tá»« PsyCap Ä‘áº¿n tÆ° duy khá»Ÿi nghiá»‡p',
        en: 'From PsyCap to Entrepreneurial Thinking',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Káº¿t ná»‘i ná»™i lá»±c vá»›i tinh tháº§n chá»§ Ä‘á»™ng, dÃ¡m thá»­, giáº£i quyáº¿t váº¥n Ä‘á» vÃ  táº¡o giÃ¡ trá»‹.',
        en: 'Connect inner resources with initiative, experimentation, problem solving, and value creation.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'BÃ i nÃ y ná»‘i bá»‘n nguá»“n lá»±c tÃ¢m lÃ½ vá»›i cÃ¡ch má»™t ngÆ°á»i chá»§ Ä‘á»™ng quan sÃ¡t, thá»­ Ã½ tÆ°á»Ÿng vÃ  hÃ nh Ä‘á»™ng trÆ°á»›c nhá»¯ng váº¥n Ä‘á» quanh mÃ¬nh.',
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
        vi: 'NhÃ¬n tháº¥y cÆ¡ há»™i trong nhá»¯ng Ä‘iá»u quen thuá»™c',
        en: 'Spot Opportunities in Familiar Things',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'NhÃ¬n tháº¥y cÆ¡ há»™i',
        en: 'Spot Opportunities',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Quan sÃ¡t nhá»¯ng báº¥t tiá»‡n vÃ  nhu cáº§u quanh mÃ¬nh nhÆ° Ä‘iá»ƒm báº¯t Ä‘áº§u cá»§a má»™t Ã½ tÆ°á»Ÿng.',
        en: 'Notice everyday frictions and needs as possible starting points for an idea.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'CÆ¡ há»™i khÃ´ng nháº¥t thiáº¿t báº¯t Ä‘áº§u tá»« má»™t Ã½ tÆ°á»Ÿng lá»›n. HÃ£y thá»­ nhÃ¬n ká»¹ nhá»¯ng Ä‘iá»u quen thuá»™c vÃ  há»i: â€œCÃ³ Ä‘iá»u gÃ¬ cÃ³ thá»ƒ tá»‘t hÆ¡n khÃ´ng?â€',
        en: 'Opportunities do not have to start with a big idea. Look closely at familiar situations and ask, â€œCould something work better?â€',
      ),
    ),
    WorkbookLesson(
      id: 'lesson_10',
      number: 10,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'TÆ° duy sÃ¡ng táº¡o â€“ Má»™t váº¥n Ä‘á», nhiá»u cÃ¡ch giáº£i',
        en: 'Creative Thinking â€“ One Problem, Many Solutions',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'TÆ° duy sÃ¡ng táº¡o',
        en: 'Creative Thinking',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Táº¡o nhiá»u phÆ°Æ¡ng Ã¡n trÆ°á»›c khi vá»™i chá»n má»™t Ä‘Ã¡p Ã¡n duy nháº¥t.',
        en: 'Generate multiple possibilities before rushing to one answer.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'SÃ¡ng táº¡o khÃ´ng chá»‰ lÃ  nghÄ© ra thá»© chÆ°a ai tá»«ng tháº¥y. ÄÃ´i khi, Ä‘Ã³ lÃ  thá»­ nhÃ¬n cÃ¹ng má»™t váº¥n Ä‘á» tá»« nhiá»u gÃ³c vÃ  káº¿t há»£p nhá»¯ng Ä‘iá»u Ä‘Ã£ cÃ³ theo cÃ¡ch má»›i.',
        en: 'Creativity is not only about inventing something no one has seen. It can mean viewing one problem from different angles and recombining what already exists.',
      ),
    ),
    WorkbookLesson(
      id: 'lesson_11',
      number: 11,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Giáº£i quyáº¿t váº¥n Ä‘á» â€“ Má»—i khÃ³ khÄƒn Ä‘á»u cÃ³ lá»‘i ra',
        en: 'Problem Solving â€“ Finding a Way Forward',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Giáº£i quyáº¿t váº¥n Ä‘á»',
        en: 'Problem Solving',
      ),
      objective: LocalizedWorkbookText(
        vi: 'TÃ¡ch má»™t váº¥n Ä‘á» thÃ nh pháº§n nhá» hÆ¡n, xÃ¡c Ä‘á»‹nh nguyÃªn nhÃ¢n vÃ  chá»n bÆ°á»›c xá»­ lÃ½ phÃ¹ há»£p.',
        en: 'Break a problem into smaller parts, identify causes, and choose a workable next step.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Khi má»™t váº¥n Ä‘á» quÃ¡ lá»›n, mÃ¬nh dá»… bá»‹ káº¹t. BÃ i nÃ y giÃºp báº¡n thu nhá» váº¥n Ä‘á» Ä‘á»ƒ nhÃ¬n rÃµ Ä‘iá»u nÃ o cÃ³ thá»ƒ xá»­ lÃ½ trÆ°á»›c.',
        en: 'A problem can feel overwhelming when it stays too large. This lesson helps you make it smaller and see what can be addressed first.',
      ),
      linkedRoute: AppRoutes.reflection,
    ),
    WorkbookLesson(
      id: 'lesson_12',
      number: 12,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Biáº¿n Ã½ tÆ°á»Ÿng thÃ nh káº¿ hoáº¡ch',
        en: 'Turn an Idea into a Plan',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Biáº¿n Ã½ tÆ°á»Ÿng thÃ nh káº¿ hoáº¡ch',
        en: 'Turn Ideas into Plans',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Chuyá»ƒn má»™t Ã½ tÆ°á»Ÿng thÃ nh má»¥c tiÃªu, bÆ°á»›c thá»±c hiá»‡n vÃ  má»‘c thá»i gian vá»«a sá»©c.',
        en: 'Turn an idea into a goal, manageable steps, and a practical timeline.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Má»™t Ã½ tÆ°á»Ÿng trá»Ÿ nÃªn dá»… báº¯t Ä‘áº§u hÆ¡n khi báº¡n biáº¿t bÆ°á»›c Ä‘áº§u tiÃªn lÃ  gÃ¬. HÃ£y biáº¿n Ä‘iá»u Ä‘ang nghÄ© thÃ nh má»™t káº¿ hoáº¡ch Ä‘á»§ nhá» Ä‘á»ƒ thá»­.',
        en: 'An idea becomes easier to start when you know the first step. Turn what you are thinking into a plan small enough to try.',
      ),
      linkedRoute: AppRoutes.goals,
    ),
    WorkbookLesson(
      id: 'lesson_13',
      number: 13,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Thá»­ nghiá»‡m Ä‘á»ƒ há»c há»i â€“ Ã tÆ°á»Ÿng khÃ´ng cáº§n hoÃ n háº£o',
        en: 'Experiment to Learn â€“ Ideas Do Not Need to Be Perfect',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Thá»­ nghiá»‡m Ä‘á»ƒ há»c há»i',
        en: 'Experiment to Learn',
      ),
      objective: LocalizedWorkbookText(
        vi: 'Thá»­ má»™t phiÃªn báº£n nhá», nháº­n pháº£n há»“i vÃ  dÃ¹ng Ä‘iá»u há»c Ä‘Æ°á»£c Ä‘á»ƒ Ä‘iá»u chá»‰nh Ã½ tÆ°á»Ÿng.',
        en: 'Try a small version, gather feedback, and use what you learn to improve the idea.',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Thá»­ nghiá»‡m khÃ´ng pháº£i Ä‘á»ƒ chá»©ng minh Ã½ tÆ°á»Ÿng hoÃ n háº£o. NÃ³ giÃºp báº¡n biáº¿t Ä‘iá»u gÃ¬ Ä‘ang Ä‘Ãºng, Ä‘iá»u gÃ¬ cáº§n sá»­a vÃ  nÃªn thá»­ gÃ¬ tiáº¿p theo.',
        en: 'An experiment is not meant to prove an idea is perfect. It helps you learn what works, what needs changing, and what to try next.',
      ),
      linkedRoute: AppRoutes.reflection,
    ),
    WorkbookLesson(
      id: 'lesson_14',
      number: 14,
      chapterId: 'chapter_03',
      title: LocalizedWorkbookText(
        vi: 'Ã tÆ°á»Ÿng táº¡o ra giÃ¡ trá»‹ nhÆ° tháº¿ nÃ o?',
        en: 'How Does an Idea Create Value?',
      ),
      shortTitle: LocalizedWorkbookText(
        vi: 'Ã tÆ°á»Ÿng táº¡o ra giÃ¡ trá»‹',
        en: 'Creating Value',
      ),
      objective: LocalizedWorkbookText(
        vi: 'NhÃ¬n láº¡i Ã½ tÆ°á»Ÿng tá»« gÃ³c Ä‘á»™ ngÆ°á»i nháº­n giÃ¡ trá»‹: ai Ä‘Æ°á»£c giÃºp, Ä‘Æ°á»£c cáº£i thiá»‡n hoáº·c Ä‘Æ°á»£c thuáº­n tiá»‡n hÆ¡n?',
        en: 'Review an idea from the perspective of the person receiving value: who is helped, improved, or made better off?',
      ),
      intro: LocalizedWorkbookText(
        vi: 'Má»™t Ã½ tÆ°á»Ÿng chá»‰ tháº­t sá»± cÃ³ Ã½ nghÄ©a khi nÃ³ táº¡o ra giÃ¡ trá»‹ cho ai Ä‘Ã³. HÃ£y thá»­ nhÃ¬n Ã½ tÆ°á»Ÿng cá»§a báº¡n tá»« gÃ³c nhÃ¬n cá»§a ngÆ°á»i sáº½ sá»­ dá»¥ng hoáº·c hÆ°á»Ÿng lá»£i.',
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

  Future<WorkbookResource?> getPublishedResourceById(String resourceId) async {
    final id = resourceId.trim();
    if (id.isEmpty) return null;

    try {
      final snapshot = await _firestore.collection('resources').doc(id).get();
      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null) return null;
      final resource = WorkbookResource.fromFirestore(snapshot.id, data);
      return resource.published ? resource : null;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied' || error.code == 'not-found') {
        return null;
      }
      rethrow;
    }
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

