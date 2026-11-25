import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/project_list_view.dart';
import 'package:provider/provider.dart';

class _TrackingClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode('[]')),
      200,
    );
  }

  @override
  void close() {
    closed = true;
    super.close();
  }
}

void main() {
  group('ApiClient Task 1.1', () {
    test('defaultTimeout is 15 seconds and can be overridden', () {
      expect(ApiClient.defaultTimeout, const Duration(seconds: 15));

      final client = ApiClient(
        client: MockClient((_) async => http.Response('[]', 200)),
        timeout: const Duration(milliseconds: 50),
      );
      expect(client.timeout, const Duration(milliseconds: 50));
      client.close();
    });

    test('close() delegates to underlying http.Client', () {
      final trackingClient = _TrackingClient();
      final apiClient = ApiClient(client: trackingClient);

      expect(trackingClient.closed, isFalse);
      apiClient.close();
      expect(trackingClient.closed, isTrue);
    });

    test('throws TimeoutException across all endpoints when request hangs', () {
      final neverCompletesClient = MockClient(
        (_) => Completer<http.Response>().future,
      );
      final apiClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: neverCompletesClient,
        timeout: const Duration(milliseconds: 20),
      );

      const sampleProject = Project(
        title: 'Timeout Project',
        description: 'Testing timeout behavior',
      );

      expect(apiClient.getProjects(), throwsA(isA<TimeoutException>()));
      expect(
        apiClient.createProject(sampleProject, token: 'tok'),
        throwsA(isA<TimeoutException>()),
      );
      expect(
        apiClient.obtainToken('user', 'pass'),
        throwsA(isA<TimeoutException>()),
      );
      expect(apiClient.logout(token: 'tok'), throwsA(isA<TimeoutException>()));
    });

    test(
      'extracts DRF detail, non_field_errors, and field errors cleanly',
      () async {
        final detailClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient(
            (_) async =>
                http.Response(jsonEncode({'detail': 'Invalid token.'}), 401),
          ),
        );
        await expectLater(
          detailClient.getProjects(),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 401)
                .having((e) => e.message, 'message', 'Invalid token.'),
          ),
        );

        final nonFieldClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'non_field_errors': [
                  'Unable to log in with provided credentials.',
                ],
              }),
              400,
            ),
          ),
        );
        await expectLater(
          nonFieldClient.obtainToken('u', 'p'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 400)
                .having(
                  (e) => e.message,
                  'message',
                  'Unable to log in with provided credentials.',
                ),
          ),
        );

        final fieldErrorClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'title': ['This field may not be blank.'],
              }),
              400,
            ),
          ),
        );
        await expectLater(
          fieldErrorClient.createProject(
            const Project(title: '', description: 'desc'),
            token: 'tok',
          ),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 400)
                .having(
                  (e) => e.message,
                  'message',
                  'title: This field may not be blank.',
                ),
          ),
        );
      },
    );

    test(
      'falls back to concise message for HTML 500 or empty error body',
      () async {
        final htmlClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient(
            (_) async => http.Response(
              '<!DOCTYPE html><html><body><h1>500 Server Error</h1></body></html>',
              500,
              reasonPhrase: 'Internal Server Error',
            ),
          ),
        );
        await expectLater(
          htmlClient.getProjects(),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 500)
                .having(
                  (e) => e.message.contains('<html>'),
                  'contains html',
                  isFalse,
                )
                .having(
                  (e) => e.message,
                  'message',
                  'Permintaan gagal (HTTP 500: Internal Server Error).',
                ),
          ),
        );

        final emptyErrorClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((_) async => http.Response('', 502)),
        );
        await expectLater(
          emptyErrorClient.logout(token: 'tok'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 502)
                .having(
                  (e) => e.message,
                  'message',
                  'Permintaan gagal dengan status HTTP 502.',
                ),
          ),
        );
      },
    );

    test('throws clear ApiException when 2xx payload is invalid JSON or wrong shape', () async {
      final nonJson200 = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) async => http.Response('<html>ok</html>', 200)),
      );
      await expectLater(
        nonJson200.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 200),
        ),
      );

      final wrongListShape = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) async => http.Response('{"items": []}', 200)),
      );
      await expectLater(
        wrongListShape.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 200),
        ),
      );

      final invalidProjectItem = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode([
              {'title': null},
            ]),
            200,
          ),
        ),
      );
      await expectLater(
        invalidProjectItem.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 200),
        ),
      );

      final wrongProjectShape = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) async => http.Response('[]', 201)),
      );
      await expectLater(
        wrongProjectShape.createProject(
          const Project(title: 'A', description: 'B'),
          token: 'tok',
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 201),
        ),
      );

      final missingToken = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) async => http.Response('{"token": ""}', 200)),
      );
      await expectLater(
        missingToken.obtainToken('u', 'p'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 200),
        ),
      );
    });
  });

  group('ApiClient lifecycle Task 1.2', () {
    testWidgets(
      'MyApp does not close externally injected ApiClient on dispose',
      (tester) async {
        final trackingClient = _TrackingClient();
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: trackingClient,
        );

        await tester.pumpWidget(MyApp(apiClient: apiClient));
        // Trigger AuthState creation so Provider<ApiClient> is instantiated too.
        final appContext = tester.element(find.byType(MaterialApp));
        appContext.read<AuthState>();

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();

        expect(trackingClient.closed, isFalse);
        apiClient.close();
        expect(trackingClient.closed, isTrue);
      },
    );

    testWidgets(
      'MyApp creates and disposes internal ApiClient cleanly when apiClient is null',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        final appContext = tester.element(find.byType(MaterialApp));
        appContext.read<AuthState>();

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ProjectListView does not close Provider or injected ApiClient on dispose',
      (tester) async {
        final injectedHttp = _TrackingClient();
        final injectedApi = ApiClient(
          baseUrl: 'https://mock.local',
          client: injectedHttp,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ProjectListView(apiClient: injectedApi)),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        expect(injectedHttp.closed, isFalse);
        injectedApi.close();

        final providedHttp = _TrackingClient();
        final providedApi = ApiClient(
          baseUrl: 'https://mock.local',
          client: providedHttp,
        );

        await tester.pumpWidget(
          Provider<ApiClient>.value(
            value: providedApi,
            child: const MaterialApp(home: Scaffold(body: ProjectListView())),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        expect(providedHttp.closed, isFalse);
        providedApi.close();
      },
    );

    testWidgets(
      'ProjectListView closes fallback ApiClient cleanly when no Provider is present',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: ProjectListView())),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );
  });
}
