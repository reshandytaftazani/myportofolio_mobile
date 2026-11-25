import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/project_list_view.dart';
import 'package:provider/provider.dart';

Widget _wrapWithProviders(
  Widget child, {
  required ApiClient apiClient,
  String? initialToken,
}) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: apiClient),
      ChangeNotifierProvider<AuthState>(
        create: (_) => AuthState(apiClient, initialToken: initialToken),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('ProjectListView refresh behavior', () {
    testWidgets(
      'keeps existing items visible while refreshing and updates on success',
      (tester) async {
        var getCount = 0;
        final refreshCompleter = Completer<http.Response>();

        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/projects/' &&
                request.method == 'GET') {
              getCount++;
              if (getCount == 1) {
                return http.Response(
                  jsonEncode([
                    {
                      'id': '1',
                      'title': 'Initial Item',
                      'description': 'Loaded on init',
                      'category': 'Mobile Development',
                    },
                  ]),
                  200,
                );
              }
              return refreshCompleter.future;
            }
            return http.Response('Not found', 404);
          }),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            const Scaffold(body: ProjectListView()),
            apiClient: apiClient,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Initial Item'), findsOneWidget);

        await tester.fling(
          find.text('Initial Item'),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Item lama tetap tampil dan tidak terganti full-screen spinner.
        expect(find.text('Initial Item'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(ProjectListView),
            matching: find.byType(ListView),
          ),
          findsOneWidget,
        );

        refreshCompleter.complete(
          http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'Refreshed Item',
                'description': 'Loaded after refresh',
                'category': 'Mobile Development',
              },
            ]),
            200,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Refreshed Item'), findsOneWidget);
        expect(getCount, 2);
      },
    );

    testWidgets(
      'keeps existing items visible and shows SnackBar when refresh fails',
      (tester) async {
        var attempt = 0;
        final refreshCompleter = Completer<http.Response>();
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((_) async {
            attempt++;
            if (attempt == 1) {
              return http.Response(
                jsonEncode([
                  {
                    'id': '1',
                    'title': 'Existing Project',
                    'description': 'Already loaded',
                    'category': 'Mobile Development',
                  },
                ]),
                200,
              );
            }
            return refreshCompleter.future;
          }),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            const Scaffold(body: ProjectListView()),
            apiClient: apiClient,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Existing Project'), findsOneWidget);

        await tester.fling(
          find.text('Existing Project'),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Existing Project'), findsOneWidget);

        refreshCompleter.complete(
          http.Response(jsonEncode({'detail': 'Refresh failed'}), 503),
        );
        await tester.pumpAndSettle();

        expect(find.text('Existing Project'), findsOneWidget);
        expect(find.text('Gagal memuat ulang: Refresh failed'), findsOneWidget);
      },
    );
  });

  group('ProjectFormPage submission and reload flow', () {
    testWidgets(
      'returning without submitting does not trigger unnecessary GET reload',
      (tester) async {
        var getCount = 0;

        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/projects/' &&
                request.method == 'GET') {
              getCount++;
              return http.Response(
                jsonEncode([
                  {
                    'id': '1',
                    'title': 'Existing Project',
                    'description': 'Should not reload on cancel',
                    'category': 'Mobile Development',
                  },
                ]),
                200,
              );
            }
            return http.Response('Not found', 404);
          }),
        );

        await tester.pumpWidget(
          MyApp(apiClient: apiClient, initialToken: 'valid-token'),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();

        expect(find.text('Existing Project'), findsOneWidget);
        expect(getCount, 1);

        await tester.tap(find.text('Tambah Proyek').first);
        await tester.pumpAndSettle();
        expect(find.byType(ProjectFormPage), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(ProjectFormPage), findsNothing);
        expect(find.byType(PortfolioSectionPage), findsOneWidget);
        expect(getCount, 1);
      },
    );

    testWidgets(
      'creating a project via LeftDrawer updates ProjectListView automatically',
      (tester) async {
        final projects = <Map<String, dynamic>>[
          {
            'id': '1',
            'title': 'Existing Project',
            'description': 'Initial list item',
            'category': 'Mobile Development',
          },
        ];
        var getCount = 0;

        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/projects/' &&
                request.method == 'GET') {
              getCount++;
              return http.Response(jsonEncode(projects), 200);
            }
            if (request.url.path == '/api/v1/projects/' &&
                request.method == 'POST') {
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              final created = {
                'id': '2',
                'title': body['title'],
                'description': body['description'],
                'category': body['category'] ?? 'Mobile Development',
                'tech_stack': body['tech_stack'] ?? '',
                'project_url': body['project_url'] ?? '',
                'project_image_url': body['project_image_url'] ?? '',
                'is_featured': body['is_featured'] ?? false,
              };
              projects.add(created);
              return http.Response(jsonEncode(created), 201);
            }
            return http.Response('Not found', 404);
          }),
        );

        await tester.pumpWidget(
          MyApp(apiClient: apiClient, initialToken: 'valid-token'),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Projects'));
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();
        expect(find.text('Existing Project'), findsOneWidget);
        expect(getCount, 1);

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Project'));
        await tester.pumpAndSettle();
        expect(find.byType(ProjectFormPage), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Proyek'),
          'Drawer Project',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
          'Added through LeftDrawer',
        );

        final saveButton = find.widgetWithText(ElevatedButton, 'Save');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(ProjectFormPage), findsNothing);
        expect(find.byType(PortfolioSectionPage), findsOneWidget);
        expect(getCount, 2);
        expect(find.text('Drawer Project'), findsOneWidget);
      },
    );

    testWidgets(
      'disables all form inputs and submit button while request is in flight',
      (tester) async {
        final postCompleter = Completer<http.Response>();

        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/projects/' &&
                request.method == 'POST') {
              return postCompleter.future;
            }
            return http.Response('Not found', 404);
          }),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            const ProjectFormPage(),
            apiClient: apiClient,
            initialToken: 'valid-token',
          ),
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Proyek'),
          'Locked Form Project',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
          'Checking disabled controls while submitting',
        );

        final saveButton = find.widgetWithText(ElevatedButton, 'Save');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pump();

        final textFields = tester.widgetList<TextField>(find.byType(TextField));
        expect(textFields, hasLength(5));
        for (final field in textFields) {
          expect(field.enabled, isFalse);
        }

        final dropdown = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>),
        );
        expect(dropdown.onChanged, isNull);

        final switchTile = tester.widget<SwitchListTile>(
          find.byType(SwitchListTile),
        );
        expect(switchTile.onChanged, isNull);

        final submitButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(submitButton.onPressed, isNull);
        expect(
          find.descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );

        postCompleter.complete(
          http.Response(
            jsonEncode({
              'id': '99',
              'title': 'Locked Form Project',
              'description': 'Checking disabled controls while submitting',
              'category': 'Mobile Development',
              'tech_stack': '',
              'project_url': '',
              'project_image_url': '',
              'is_featured': false,
            }),
            201,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Proyek Berhasil Disimpan'), findsOneWidget);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
        await tester.pumpAndSettle();

        for (final field in tester.widgetList<TextField>(
          find.byType(TextField),
        )) {
          expect(field.enabled, isTrue);
        }
        expect(
          tester
              .widget<DropdownButton<String>>(
                find.byType(DropdownButton<String>),
              )
              .onChanged,
          isNotNull,
        );
        expect(
          tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
          isNotNull,
        );
      },
    );
  });
}
