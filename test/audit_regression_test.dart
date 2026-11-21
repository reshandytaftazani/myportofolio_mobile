import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/portfolio_menu.dart';
import 'package:myportofolio_mobile/forms/form_validators.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/portfolio_detail_page.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';
import 'package:myportofolio_mobile/widgets/experience_card.dart';

void main() {
  group('Home layout overflow regression', () {
    for (final width in [320.0, 360.0, 390.0, 400.0]) {
      testWidgets('MyHomePage renders without overflow at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        expect(find.text('Active Student'), findsOneWidget);
        expect(find.text('Projects'), findsOneWidget);
        expect(find.text('Experiences'), findsOneWidget);
        expect(find.text('Education'), findsOneWidget);
        expect(find.text('Skills'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'MyHomePage renders without overflow on narrow phone with large text scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const MyApp(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Active Student'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Experience date status consistency', () {
    testWidgets(
      'startedAt without endedAt and isOngoing == false shows Belum diisi in card and detail',
      (tester) async {
        final exp = Experience(
          title: 'Research Assistant',
          description: 'Meneliti pemrosesan bahasa alami.',
          startedAt: DateTime(2025, 2, 1),
          endedAt: null,
          isOngoing: false,
        );

        expect(exp.endStatus, ExperienceEndStatus.unknown);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ExperienceCard(experience: exp)),
          ),
        );
        expect(find.text('Feb 2025 – Belum diisi'), findsOneWidget);
        expect(find.textContaining('Sekarang'), findsNothing);

        await tester.pumpWidget(
          MaterialApp(home: PortfolioDetailPage.experience(exp)),
        );
        expect(find.text('1 Februari 2025'), findsOneWidget);
        expect(find.text('Belum diisi'), findsOneWidget);
        expect(find.textContaining('Sekarang'), findsNothing);
      },
    );

    testWidgets(
      'isOngoing == true shows Sekarang in card and Sekarang (Ongoing) in detail',
      (tester) async {
        final exp = Experience(
          title: 'Teaching Assistant',
          description: 'Mengajar kelas praktikum.',
          startedAt: DateTime(2025, 8, 1),
          endedAt: null,
          isOngoing: true,
        );

        expect(exp.endStatus, ExperienceEndStatus.ongoing);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ExperienceCard(experience: exp)),
          ),
        );
        expect(find.text('Agu 2025 – Sekarang'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(home: PortfolioDetailPage.experience(exp)),
        );
        expect(find.text('1 Agustus 2025'), findsOneWidget);
        expect(find.text('Sekarang (Ongoing)'), findsOneWidget);
      },
    );

    testWidgets(
      'completed experience shows formatted end date in both card and detail',
      (tester) async {
        final exp = Experience(
          title: 'Mobile Intern',
          description: 'Mengembangkan aplikasi Flutter.',
          startedAt: DateTime(2025, 1, 10),
          endedAt: DateTime(2025, 5, 30),
          isOngoing: false,
        );

        expect(exp.endStatus, ExperienceEndStatus.completed);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ExperienceCard(experience: exp)),
          ),
        );
        expect(find.text('Jan 2025 – Mei 2025'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(home: PortfolioDetailPage.experience(exp)),
        );
        expect(find.text('10 Januari 2025'), findsOneWidget);
        expect(find.text('30 Mei 2025'), findsOneWidget);
      },
    );
  });

  group('Portfolio section decoupling and empty state', () {
    testWidgets(
      'buildPortfolioMenuItems supports injected empty PortfolioDataSource',
      (tester) async {
        final emptyMenus = buildPortfolioMenuItems(
          dataSource: const PortfolioDataSource(),
        );
        final projectsMenu = emptyMenus.firstWhere(
          (item) => item.section == PortfolioSection.projects,
        );

        await tester.pumpWidget(
          MaterialApp(home: Builder(builder: projectsMenu.pageBuilder)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PortfolioSectionPage), findsOneWidget);
        expect(find.text('Belum ada data Projects'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Shared form validator', () {
    test(
      'validateRequiredText handles empty, whitespace, maxLength, and suffix',
      () {
        expect(
          validateRequiredText(null, fieldLabel: 'Judul'),
          'Judul tidak boleh kosong.',
        );
        expect(
          validateRequiredText('   ', fieldLabel: 'Judul', emptySuffix: '!'),
          'Judul tidak boleh kosong!',
        );
        expect(
          validateRequiredText('abcdef', fieldLabel: 'Judul', maxLength: 5),
          'Judul maksimal 5 karakter.',
        );
        expect(
          validateRequiredText('abcde', fieldLabel: 'Judul', maxLength: 5),
          isNull,
        );
      },
    );
  });
}
