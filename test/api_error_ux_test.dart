import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/api_error_formatter.dart';
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
  group('formatApiError', () {
    test('formats TimeoutException, SocketException, ClientException, and ApiException cleanly', () {
      expect(
        formatApiError(TimeoutException('timed out')),
        'Koneksi ke server habis waktu. Periksa jaringan lalu coba lagi.',
      );
      expect(
        formatApiError(const SocketException('Connection refused')),
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
      expect(
        formatApiError(http.ClientException('Failed host lookup')),
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
      expect(
        formatApiError(
          const ApiException(400, 'Invalid credentials.'),
          actionLabel: 'Login gagal',
        ),
        'Login gagal (400): Invalid credentials.',
      );
      expect(
        formatApiError(
          const ApiException(500, '<html><body>500</body></html>'),
          actionLabel: 'Login gagal',
        ),
        'Login gagal (500): Terjadi kesalahan pada server.',
      );
      expect(
        formatApiError(StateError('boom'), actionLabel: 'Login gagal'),
        'Login gagal. Terjadi kesalahan tak terduga.',
      );
    });
  });

  group('LoginScreen error UX', () {
    testWidgets('shows summarized message on HTML 500 response', (
      tester,
    ) async {
      final apiClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient(
          (_) async => http.Response(
            '<html><body><h1>500 Internal Server Error</h1></body></html>',
            500,
            reasonPhrase: 'Internal Server Error',
          ),
        ),
      );

      await tester.pumpWidget(
        _wrapWithProviders(const LoginScreen(), apiClient: apiClient),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'admin');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Login gagal (500): Permintaan gagal (HTTP 500: Internal Server Error).',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('<html>'), findsNothing);
    });

    testWidgets('shows friendly message on TimeoutException', (tester) async {
      final apiClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 20),
      );

      await tester.pumpWidget(
        _wrapWithProviders(const LoginScreen(), apiClient: apiClient),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'admin');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Koneksi ke server habis waktu. Periksa jaringan lalu coba lagi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows friendly message on SocketException', (tester) async {
      final apiClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient(
          (_) async => throw const SocketException('Network unreachable'),
        ),
      );

      await tester.pumpWidget(
        _wrapWithProviders(const LoginScreen(), apiClient: apiClient),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'admin');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        ),
        findsOneWidget,
      );
    });
  });

  group('ProjectFormPage & ProjectListView error UX', () {
    testWidgets(
      'ProjectFormPage shows friendly message on SocketException and DRF 400',
      (tester) async {
        var return400 = false;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((_) async {
            if (return400) {
              return http.Response(
                jsonEncode({
                  'title': ['Project with this title already exists.'],
                }),
                400,
              );
            }
            throw const SocketException('Connection refused');
          }),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            const ProjectFormPage(),
            apiClient: apiClient,
            initialToken: 'tok-123',
          ),
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Proyek'),
          'My Project',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
          'Project description',
        );

        final saveButton = find.widgetWithText(FilledButton, 'Simpan');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          ),
          findsOneWidget,
        );

        ScaffoldMessenger.of(tester.element(find.byType(ProjectFormPage)))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();

        return400 = true;
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Gagal menyimpan proyek (400): title: Project with this title already exists.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ProjectListView shows friendly network error instead of raw exception',
      (tester) async {
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient(
            (_) async => throw const SocketException('Connection refused'),
          ),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            const Scaffold(body: ProjectListView()),
            apiClient: apiClient,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat daftar proyek'), findsOneWidget);
        expect(
          find.text(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('SocketException'), findsNothing);
      },
    );

    testWidgets(
      'ProjectListView shows concise message on TimeoutException/HTML 500 and recovers on Retry',
      (tester) async {
        var attempt = 0;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          timeout: const Duration(milliseconds: 20),
          client: MockClient((_) async {
            attempt++;
            if (attempt == 1) {
              return Completer<http.Response>().future;
            }
            if (attempt == 2) {
              return http.Response(
                '<html><body><h1>500 Server Error</h1></body></html>',
                500,
                reasonPhrase: 'Internal Server Error',
              );
            }
            return http.Response(
              jsonEncode([
                {
                  'id': '1',
                  'title': 'Recovered Project',
                  'description': 'Loaded after retry',
                  'category': 'Mobile Development',
                },
              ]),
              200,
            );
          }),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            const Scaffold(body: ProjectListView()),
            apiClient: apiClient,
          ),
        );
        await tester.pump(const Duration(milliseconds: 40));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Koneksi ke server habis waktu. Periksa jaringan lalu coba lagi.',
          ),
          findsOneWidget,
        );

        await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
        await tester.pumpAndSettle();

        expect(
          find.text('Permintaan gagal (HTTP 500: Internal Server Error).'),
          findsOneWidget,
        );
        expect(find.textContaining('<html>'), findsNothing);

        await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
        await tester.pumpAndSettle();

        expect(find.text('Recovered Project'), findsOneWidget);
      },
    );

    testWidgets(
      'ProjectFormPage shows friendly message on TimeoutException and redirects to LoginScreen on 401',
      (tester) async {
        var return401 = false;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          timeout: const Duration(milliseconds: 20),
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/auth/logout/') {
              return http.Response('', 204);
            }
            if (return401) {
              return http.Response(
                jsonEncode({'detail': 'Invalid token.'}),
                401,
              );
            }
            return Completer<http.Response>().future;
          }),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            const ProjectFormPage(),
            apiClient: apiClient,
            initialToken: 'expired-token',
          ),
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama Proyek'),
          'Timeout Project',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
          'Testing timeout and 401 handling',
        );

        final saveButton = find.widgetWithText(FilledButton, 'Simpan');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pump(const Duration(milliseconds: 40));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Koneksi ke server habis waktu. Periksa jaringan lalu coba lagi.',
          ),
          findsOneWidget,
        );

        ScaffoldMessenger.of(tester.element(find.byType(ProjectFormPage)))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();

        return401 = true;
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );
  });
}
