import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/portfolio_detail_page.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/tech_stack_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/education_card.dart';
import 'package:myportofolio_mobile/widgets/experience_card.dart';
import 'package:myportofolio_mobile/widgets/skill_card.dart';
import 'package:myportofolio_mobile/widgets/tech_stack_card.dart';
import 'package:provider/provider.dart';

Finder _field(String label) => find.ancestor(
  of: find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  ),
  matching: find.byType(TextFormField),
);

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, 'Simpan');
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
  await tester.pumpAndSettle();
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
}

void main() {
  group('Non-project sections GET, Error/Retry, and Detail screen flows', () {
    testWidgets(
      'Experiences section handles GET error, Retry recovery, and opens Detail screen',
      (tester) async {
        var attempts = 0;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/experiences/' &&
                request.method == 'GET') {
              attempts++;
              if (attempts == 1) {
                throw const SocketException('Offline');
              }
              return http.Response(
                jsonEncode([
                  {
                    'id': 'exp-1',
                    'title': 'Mobile Engineering Intern',
                    'company': 'PT Nusantara Tech',
                    'description': 'Membangun aplikasi Flutter terintegrasi.',
                    'category': 'internship',
                    'started_at': '2026-01-15',
                    'ended_at': null,
                    'is_ongoing': true,
                    'star_count': 3,
                    'is_starred': false,
                    'starred_by_names': '',
                  },
                ]),
                200,
              );
            }
            return http.Response(jsonEncode([]), 200);
          }),
        );

        await tester.pumpWidget(MyApp(apiClient: apiClient));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Experiences'));
        await tester.tap(find.text('Experiences'));
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat daftar pengalaman'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Coba Lagi'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
        await tester.pumpAndSettle();

        expect(attempts, 2);
        expect(find.byType(ExperienceCard), findsOneWidget);
        expect(find.text('Mobile Engineering Intern'), findsOneWidget);

        await tester.tap(find.byType(ExperienceCard));
        await tester.pumpAndSettle();

        expect(find.byType(PortfolioDetailPage), findsOneWidget);
        expect(find.text('Detail Pengalaman'), findsOneWidget);
        expect(find.text('Mobile Engineering Intern'), findsOneWidget);
        expect(find.text('PT Nusantara Tech'), findsWidgets);
        expect(
          find.text('Membangun aplikasi Flutter terintegrasi.'),
          findsOneWidget,
        );
        expect(find.text('Sekarang (Ongoing)'), findsOneWidget);
      },
    );

    testWidgets(
      'Education section handles GET error, Retry recovery, and opens Detail screen',
      (tester) async {
        var attempts = 0;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/education/' &&
                request.method == 'GET') {
              attempts++;
              if (attempts == 1) {
                return http.Response('Server Error', 500);
              }
              return http.Response(
                jsonEncode([
                  {
                    'id': 11,
                    'school_name': 'Universitas Indonesia',
                    'period': '2024 - Sekarang',
                    'detail': 'S1 Ilmu Komputer Fasilkom UI',
                    'start_year': 2024,
                    'star_count': 2,
                    'is_starred': false,
                    'starred_by_names': '',
                  },
                ]),
                200,
              );
            }
            return http.Response(jsonEncode([]), 200);
          }),
        );

        await tester.pumpWidget(MyApp(apiClient: apiClient));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Education'));
        await tester.tap(find.text('Education'));
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat daftar pendidikan'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
        await tester.pumpAndSettle();

        expect(attempts, 2);
        expect(find.byType(EducationCard), findsOneWidget);
        expect(find.text('Universitas Indonesia'), findsOneWidget);

        await tester.tap(find.byType(EducationCard));
        await tester.pumpAndSettle();

        expect(find.byType(PortfolioDetailPage), findsOneWidget);
        expect(find.text('Detail Pendidikan'), findsOneWidget);
        expect(find.text('Universitas Indonesia'), findsWidgets);
        expect(find.text('S1 Ilmu Komputer Fasilkom UI'), findsOneWidget);
        expect(find.text('2024'), findsOneWidget);
      },
    );

    testWidgets(
      'Skills section handles GET error, Retry recovery, and opens Detail screen',
      (tester) async {
        var attempts = 0;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/skills/' &&
                request.method == 'GET') {
              attempts++;
              if (attempts == 1) {
                throw const SocketException('Network down');
              }
              return http.Response(
                jsonEncode([
                  {
                    'id': 'skill-1',
                    'title': 'Flutter & Dart',
                    'description': 'Membangun antarmuka mobile responsif.',
                    'level': 'Intermediate',
                    'code_snippet': 'Widget build(BuildContext context) {}',
                    'star_count': 5,
                    'is_starred': true,
                    'starred_by_names': 'admin',
                  },
                ]),
                200,
              );
            }
            return http.Response(jsonEncode([]), 200);
          }),
        );

        await tester.pumpWidget(MyApp(apiClient: apiClient));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Skills'));
        await tester.tap(find.text('Skills'));
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat daftar keahlian'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
        await tester.pumpAndSettle();

        expect(attempts, 2);
        expect(find.byType(SkillCard), findsOneWidget);
        expect(find.text('Flutter & Dart'), findsOneWidget);

        await tester.tap(find.byType(SkillCard));
        await tester.pumpAndSettle();

        expect(find.byType(PortfolioDetailPage), findsOneWidget);
        expect(find.text('Detail Keahlian'), findsOneWidget);
        expect(find.text('Flutter & Dart'), findsOneWidget);
        expect(find.text('Intermediate'), findsWidgets);
        expect(
          find.text('Widget build(BuildContext context) {}'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Tech Stack tab handles GET error, Retry recovery, and opens Detail screen',
      (tester) async {
        var attempts = 0;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/techstacks/' &&
                request.method == 'GET') {
              attempts++;
              if (attempts == 1) {
                return http.Response('Internal error', 500);
              }
              return http.Response(
                jsonEncode([
                  {
                    'id': 7,
                    'name': 'Django REST Framework',
                    'icon_url': 'data:image/svg+xml;utf8,<svg></svg>',
                    'filename': 'api_views.py',
                    'code_snippet': '@api_view(["GET", "POST"])',
                    'order': 2,
                    'star_count': 1,
                    'is_starred': false,
                    'starred_by_names': '',
                  },
                ]),
                200,
              );
            }
            return http.Response(jsonEncode([]), 200);
          }),
        );

        await tester.pumpWidget(MyApp(apiClient: apiClient));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(Tab, 'Tech Stack'));
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat daftar tech stack'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
        await tester.pumpAndSettle();

        expect(attempts, 2);
        expect(find.byType(TechStackCard), findsOneWidget);
        expect(find.text('Django REST Framework'), findsOneWidget);

        await tester.tap(find.byType(TechStackCard));
        await tester.pumpAndSettle();

        expect(find.byType(PortfolioDetailPage), findsOneWidget);
        expect(find.text('Detail Tech Stack'), findsOneWidget);
        expect(find.text('Django REST Framework'), findsOneWidget);
        expect(find.text('api_views.py'), findsWidgets);
        expect(find.text('@api_view(["GET", "POST"])'), findsOneWidget);
      },
    );
  });

  group(
    'Non-project authenticated POST, form lock, and auto-refresh flows',
    () {
      testWidgets(
        'Experiences POST locks controls while submitting, excludes id, refreshes list, and cancel skips reload',
        (tester) async {
          final experiences = <Map<String, dynamic>>[];
          var getCount = 0;
          String? authHeader;
          Map<String, dynamic>? postedBody;
          final postCompleter = Completer<http.Response>();

          final apiClient = ApiClient(
            baseUrl: 'https://mock.local',
            client: MockClient((request) async {
              if (request.url.path == '/api/v1/experiences/' &&
                  request.method == 'GET') {
                getCount++;
                return http.Response(jsonEncode(experiences), 200);
              }
              if (request.url.path == '/api/v1/experiences/' &&
                  request.method == 'POST') {
                authHeader = request.headers['Authorization'];
                postedBody = jsonDecode(request.body) as Map<String, dynamic>;
                return postCompleter.future;
              }
              return http.Response(jsonEncode([]), 200);
            }),
          );

          await tester.pumpWidget(
            MyApp(apiClient: apiClient, initialToken: 'exp-token'),
          );
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Experiences'));
          await tester.tap(find.text('Experiences'));
          await tester.pumpAndSettle();
          expect(find.text('Belum ada pengalaman.'), findsOneWidget);
          expect(getCount, 1);

          // Buka form lalu batal kembali -> tidak boleh memicu GET ulang.
          await tester.tap(find.text('Tambah Pengalaman').first);
          await tester.pumpAndSettle();
          expect(find.byType(ExperienceFormPage), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(getCount, 1);

          // Buka form lagi dan kirim data valid.
          await tester.tap(find.text('Tambah Pengalaman').first);
          await tester.pumpAndSettle();

          await tester.enterText(_field('Nama Pengalaman'), 'Lead Flutter Dev');
          await tester.enterText(
            _field('Perusahaan / Organisasi (Opsional)'),
            'Fasilkom Lab',
          );
          await tester.enterText(
            _field('Deskripsi Pengalaman'),
            'Memimpin pengembangan aplikasi mobile.',
          );

          await _tapSave(tester);
          await tester.pump();

          // Saat request in-flight, semua input & tombol Simpan terkunci.
          for (final tf in tester.widgetList<TextField>(
            find.byType(TextField),
          )) {
            expect(tf.enabled, isFalse);
          }
          expect(
            tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
            isNull,
          );

          final created = {
            'id': 'exp-created-1',
            'title': 'Lead Flutter Dev',
            'company': 'Fasilkom Lab',
            'description': 'Memimpin pengembangan aplikasi mobile.',
            'category': 'work',
            'started_at': null,
            'ended_at': null,
            'is_ongoing': false,
            'star_count': 0,
            'is_starred': false,
            'starred_by_names': '',
          };
          experiences.add(created);
          postCompleter.complete(http.Response(jsonEncode(created), 201));
          await tester.pumpAndSettle();

          expect(authHeader, 'Token exp-token');
          expect(postedBody, isNotNull);
          expect(postedBody!.containsKey('id'), isFalse);
          expect(find.text('Pengalaman Berhasil Disimpan'), findsOneWidget);

          await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
          await tester.pumpAndSettle();

          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(find.byType(PortfolioSectionPage), findsOneWidget);
          expect(getCount, 2);
          expect(find.text('Lead Flutter Dev'), findsOneWidget);
        },
      );

      testWidgets(
        'Education, Skills, and Tech Stack POST send token without id and auto-refresh their lists',
        (tester) async {
          final educations = <Map<String, dynamic>>[];
          final skills = <Map<String, dynamic>>[];
          final techStacks = <Map<String, dynamic>>[];
          final postedPaths = <String>[];

          final apiClient = ApiClient(
            baseUrl: 'https://mock.local',
            client: MockClient((request) async {
              if (request.method == 'GET') {
                switch (request.url.path) {
                  case '/api/v1/education/':
                    return http.Response(jsonEncode(educations), 200);
                  case '/api/v1/skills/':
                    return http.Response(jsonEncode(skills), 200);
                  case '/api/v1/techstacks/':
                    return http.Response(jsonEncode(techStacks), 200);
                  default:
                    return http.Response(jsonEncode([]), 200);
                }
              }
              if (request.method == 'POST') {
                expect(request.headers['Authorization'], 'Token multi-tok');
                final body = jsonDecode(request.body) as Map<String, dynamic>;
                expect(body.containsKey('id'), isFalse);
                postedPaths.add(request.url.path);

                if (request.url.path == '/api/v1/education/') {
                  final created = {'id': 10, ...body};
                  educations.add(created);
                  return http.Response(jsonEncode(created), 201);
                }
                if (request.url.path == '/api/v1/skills/') {
                  final created = {'id': 'sk-10', ...body};
                  skills.add(created);
                  return http.Response(jsonEncode(created), 201);
                }
                if (request.url.path == '/api/v1/techstacks/') {
                  final created = {'id': 20, ...body};
                  techStacks.add(created);
                  return http.Response(jsonEncode(created), 201);
                }
              }
              return http.Response('Not found', 404);
            }),
          );

          await tester.pumpWidget(
            MyApp(apiClient: apiClient, initialToken: 'multi-tok'),
          );
          await tester.pumpAndSettle();

          // 1. Education
          await tester.ensureVisible(find.text('Education'));
          await tester.tap(find.text('Education'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Tambah Pendidikan').first);
          await tester.pumpAndSettle();
          expect(find.byType(EducationFormPage), findsOneWidget);

          await tester.enterText(
            _field('Nama Sekolah / Institusi'),
            'Universitas Indonesia',
          );
          await tester.enterText(_field('Periode'), '2024 - 2028');
          await tester.enterText(_field('Detail Pendidikan'), 'Ilmu Komputer');
          await tester.enterText(_field('Tahun Mulai'), '2024');
          await _tapSave(tester);
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(find.text('Universitas Indonesia'), findsOneWidget);

          // Kembali ke Home
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          // 2. Skills
          await tester.ensureVisible(find.text('Skills'));
          await tester.tap(find.text('Skills'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Tambah Keahlian').first);
          await tester.pumpAndSettle();
          expect(find.byType(SkillFormPage), findsOneWidget);

          await tester.enterText(_field('Nama Keahlian'), 'Django & DRF');
          await tester.enterText(_field('Level'), 'Advanced');
          await tester.enterText(
            _field('Deskripsi Keahlian'),
            'REST API dengan TokenAuthentication.',
          );
          await _tapSave(tester);
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(find.text('Django & DRF'), findsOneWidget);

          // Kembali ke Home
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          // 3. Tech Stack tab inside Projects
          await tester.ensureVisible(find.text('Projects'));
          await tester.tap(find.text('Projects'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(Tab, 'Tech Stack'));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          expect(find.byType(TechStackFormPage), findsOneWidget);

          await tester.enterText(_field('Nama Tech Stack'), 'PostgreSQL');
          await tester.enterText(
            _field('URL Ikon'),
            'https://cdn.example.com/postgres.png',
          );
          await tester.enterText(_field('Nama File'), 'schema.sql');
          await tester.enterText(
            _field('Cuplikan Kode'),
            'SELECT * FROM portfolio;',
          );
          await tester.enterText(_field('Urutan Tampil'), '3');
          await _tapSave(tester);
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(find.text('PostgreSQL'), findsOneWidget);
          expect(postedPaths, [
            '/api/v1/education/',
            '/api/v1/skills/',
            '/api/v1/techstacks/',
          ]);
        },
      );

      testWidgets(
        '401 on non-project form logs out, opens LoginScreen, preserves form values, and succeeds on retry',
        (tester) async {
          final seenAuthHeaders = <String?>[];
          final apiClient = ApiClient(
            baseUrl: 'https://mock.local',
            client: MockClient((request) async {
              if (request.url.path == '/api/v1/auth/logout/') {
                return http.Response('', 204);
              }
              if (request.url.path == '/api/v1/auth/token/' &&
                  request.method == 'POST') {
                return http.Response(jsonEncode({'token': 'fresh-token'}), 200);
              }
              if (request.url.path == '/api/v1/education/' &&
                  request.method == 'POST') {
                final auth = request.headers['Authorization'];
                seenAuthHeaders.add(auth);
                if (auth == 'Token revoked-token') {
                  return http.Response(
                    jsonEncode({'detail': 'Invalid token.'}),
                    401,
                  );
                }
                final body = jsonDecode(request.body) as Map<String, dynamic>;
                return http.Response(jsonEncode({'id': 42, ...body}), 201);
              }
              return http.Response(jsonEncode([]), 200);
            }),
          );

          await tester.pumpWidget(
            MyApp(apiClient: apiClient, initialToken: 'revoked-token'),
          );
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Education'));
          await tester.tap(find.text('Education'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Tambah Pendidikan').first);
          await tester.pumpAndSettle();

          await tester.enterText(
            _field('Nama Sekolah / Institusi'),
            'UI Depok',
          );
          await tester.enterText(_field('Periode'), '2024 - 2028');
          await tester.enterText(_field('Detail Pendidikan'), 'Ilmu Komputer');
          await tester.enterText(_field('Tahun Mulai'), '2024');

          await _tapSave(tester);
          await tester.pumpAndSettle();

          // Sesi dibersihkan dan pengguna diarahkan ke LoginScreen.
          expect(find.byType(LoginScreen), findsOneWidget);
          final loginCtx = tester.element(find.byType(LoginScreen));
          expect(loginCtx.read<AuthState>().isLoggedIn, isFalse);

          // Login ulang dengan token baru.
          await tester.enterText(_field('Username'), 'admin');
          await tester.enterText(_field('Password'), 'secret');
          await tester.tap(find.widgetWithText(FilledButton, 'Login'));
          await tester.pumpAndSettle();

          expect(find.byType(LoginScreen), findsNothing);
          expect(find.byType(EducationFormPage), findsOneWidget);
          expect(
            find.text(
              'Login berhasil. Tekan Simpan untuk mengirim ulang pendidikan.',
            ),
            findsOneWidget,
          );
          // Nilai isian sebelumnya tetap utuh.
          expect(
            tester
                .widget<TextFormField>(_field('Nama Sekolah / Institusi'))
                .controller
                ?.text,
            'UI Depok',
          );

          // Kirim ulang dengan token baru -> berhasil.
          await _tapSave(tester);
          await tester.pumpAndSettle();

          expect(find.text('Pendidikan Berhasil Disimpan'), findsOneWidget);
          expect(seenAuthHeaders, ['Token revoked-token', 'Token fresh-token']);
        },
      );
    },
  );

  group('PortfolioDetailPage authenticated DELETE flow', () {
    testWidgets('hides delete button when item has no id', (tester) async {
      const localOnlyExp = Experience(
        title: 'Local Draft Experience',
        description: 'Tanpa id dari server.',
      );

      await tester.pumpWidget(
        MaterialApp(home: PortfolioDetailPage.experience(localOnlyExp)),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Hapus'), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets(
      'unauthenticated delete redirects to LoginScreen and Batal cancels without sending DELETE',
      (tester) async {
        var deleteCalled = false;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/auth/token/' &&
                request.method == 'POST') {
              return http.Response(jsonEncode({'token': 'del-token'}), 200);
            }
            if (request.method == 'DELETE') {
              deleteCalled = true;
              return http.Response('', 204);
            }
            if (request.url.path == '/api/v1/experiences/' &&
                request.method == 'GET') {
              return http.Response(
                jsonEncode([
                  {
                    'id': 'exp-guard-1',
                    'title': 'Guarded Experience',
                    'description': 'Membutuhkan login sebelum hapus.',
                    'category': 'work',
                  },
                ]),
                200,
              );
            }
            return http.Response(jsonEncode([]), 200);
          }),
        );

        await tester.pumpWidget(MyApp(apiClient: apiClient));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Experiences'));
        await tester.tap(find.text('Experiences'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guarded Experience'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Hapus'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        await tester.enterText(_field('Username'), 'admin');
        await tester.enterText(_field('Password'), 'secret');
        await tester.tap(find.widgetWithText(FilledButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.text('Hapus pengalaman?'), findsOneWidget);
        await tester.tap(find.widgetWithText(TextButton, 'Batal'));
        await tester.pumpAndSettle();

        expect(deleteCalled, isFalse);
        expect(find.byType(PortfolioDetailPage), findsOneWidget);
      },
    );

    testWidgets(
      'confirmed DELETE removes item on backend and auto-refreshes Experiences, Education, Skills, and Tech Stack lists',
      (tester) async {
        final experiences = <Map<String, dynamic>>[
          {
            'id': 'exp-del-1',
            'title': 'Experience To Delete',
            'description': 'Akan dihapus.',
            'category': 'work',
          },
        ];
        final educations = <Map<String, dynamic>>[
          {
            'id': 31,
            'school_name': 'Education To Delete',
            'period': '2020 - 2024',
            'detail': 'Akan dihapus.',
            'start_year': 2020,
          },
        ];
        final skills = <Map<String, dynamic>>[
          {
            'id': 'skill-del-1',
            'title': 'Skill To Delete',
            'description': 'Akan dihapus.',
            'level': 'Beginner',
          },
        ];
        final techStacks = <Map<String, dynamic>>[
          {
            'id': 41,
            'name': 'TechStack To Delete',
            'icon_url': 'data:image/svg+xml;utf8,<svg></svg>',
            'filename': 'del.dart',
            'code_snippet': 'void main() {}',
            'order': 1,
          },
        ];
        final deletedPaths = <String>[];

        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.method == 'GET') {
              switch (request.url.path) {
                case '/api/v1/experiences/':
                  return http.Response(jsonEncode(experiences), 200);
                case '/api/v1/education/':
                  return http.Response(jsonEncode(educations), 200);
                case '/api/v1/skills/':
                  return http.Response(jsonEncode(skills), 200);
                case '/api/v1/techstacks/':
                  return http.Response(jsonEncode(techStacks), 200);
                default:
                  return http.Response(jsonEncode([]), 200);
              }
            }
            if (request.method == 'DELETE') {
              expect(request.headers['Authorization'], 'Token del-tok');
              deletedPaths.add(request.url.path);
              switch (request.url.path) {
                case '/api/v1/experiences/exp-del-1/':
                  experiences.clear();
                  return http.Response('', 204);
                case '/api/v1/education/31/':
                  educations.clear();
                  return http.Response('', 204);
                case '/api/v1/skills/skill-del-1/':
                  skills.clear();
                  return http.Response('', 204);
                case '/api/v1/techstacks/41/':
                  techStacks.clear();
                  return http.Response('', 204);
              }
            }
            return http.Response('Not found', 404);
          }),
        );

        await tester.pumpWidget(
          MyApp(apiClient: apiClient, initialToken: 'del-tok'),
        );
        await tester.pumpAndSettle();

        // 1. Delete Experience
        await tester.ensureVisible(find.text('Experiences'));
        await tester.tap(find.text('Experiences'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Experience To Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Hapus'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
        await tester.pumpAndSettle();

        expect(find.text('Pengalaman berhasil dihapus.'), findsOneWidget);
        expect(find.text('Experience To Delete'), findsNothing);
        expect(find.text('Belum ada pengalaman.'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // 2. Delete Education
        await tester.ensureVisible(find.text('Education'));
        await tester.tap(find.text('Education'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Education To Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Hapus'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
        await tester.pumpAndSettle();

        expect(find.text('Pendidikan berhasil dihapus.'), findsOneWidget);
        expect(find.text('Education To Delete'), findsNothing);
        expect(find.text('Belum ada riwayat pendidikan.'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // 3. Delete Skill
        await tester.ensureVisible(find.text('Skills'));
        await tester.tap(find.text('Skills'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Skill To Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Hapus'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
        await tester.pumpAndSettle();

        expect(find.text('Keahlian berhasil dihapus.'), findsOneWidget);
        expect(find.text('Skill To Delete'), findsNothing);
        expect(find.text('Belum ada keahlian.'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // 4. Delete Tech Stack
        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(Tab, 'Tech Stack'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('TechStack To Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Hapus'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
        await tester.pumpAndSettle();

        expect(find.text('Tech stack berhasil dihapus.'), findsOneWidget);
        expect(find.text('TechStack To Delete'), findsNothing);
        expect(find.text('Belum ada tech stack.'), findsOneWidget);

        expect(deletedPaths, [
          '/api/v1/experiences/exp-del-1/',
          '/api/v1/education/31/',
          '/api/v1/skills/skill-del-1/',
          '/api/v1/techstacks/41/',
        ]);
      },
    );
  });
}
