import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> saveForm(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.ancestor(
  of: find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  ),
  matching: find.byType(TextFormField),
);

void main() {
  testWidgets('drawer renders without overflow and navigates both ways', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await openDrawer(tester);
    expect(find.text('My Portfolio'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await openDrawer(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('project card pushes form and system Back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await tester.tap(find.text('TUTUP'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'form validates, summarizes all inputs and resets for another submission',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
      await saveForm(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(field('Nama Proyek'), '   ');
      await tester.enterText(field('Deskripsi Proyek'), '   ');
      await saveForm(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(field('Nama Proyek'), 'Proyek A');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi A');
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile Development').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('Teknologi yang Digunakan'), 'Flutter');
      await tester.enterText(field('Tautan Proyek'), 'https://example.com');
      await saveForm(tester);
      for (final text in [
        'Nama Proyek: Proyek A',
        'Deskripsi: Deskripsi A',
        'Kategori: Mobile Development',
        'Teknologi: Flutter',
        'Tautan: https://example.com',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      for (final editable in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(editable.controller.text, isEmpty);
      }
      expect(
        tester
            .state<FormFieldState<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .value,
        'Web Development',
      );
      await tester.enterText(field('Nama Proyek'), 'Proyek B');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi B');
      await saveForm(tester);
      for (final text in [
        'Nama Proyek: Proyek B',
        'Deskripsi: Deskripsi B',
        'Kategori: Web Development',
        'Teknologi: ',
        'Tautan: ',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'phone form remains scrollable with keyboard and drawer supports large text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const ProjectFormPage(),
        ),
      );
      await openDrawer(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Add Project'));
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nama Proyek'), 'Proyek Ponsel');
      await tester.enterText(field('Deskripsi Proyek'), 'Deskripsi ponsel');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await saveForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.ensureVisible(find.text('OK'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
