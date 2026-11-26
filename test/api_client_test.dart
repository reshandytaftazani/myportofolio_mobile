import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';
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
  group('ApiClient', () {
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

    test(
      'GET endpoints parse experiences, education, skills, and tech stacks',
      () async {
        final seenRequests = <String>[];
        final client = ApiClient(
          baseUrl: 'https://mock.local/',
          client: MockClient((request) async {
            seenRequests.add('${request.method} ${request.url.path}');
            expect(request.headers['Accept'], 'application/json');
            expect(request.headers.containsKey('Authorization'), isFalse);

            switch (request.url.path) {
              case '/api/v1/experiences/':
                return http.Response(
                  jsonEncode([
                    {
                      'id': 'exp-1',
                      'title': 'Mobile Intern',
                      'company': 'Tech Corp',
                      'description': 'Membangun aplikasi Flutter.',
                      'category': 'internship',
                      'category_display': 'Internship',
                      'started_at': '2025-06-01',
                      'ended_at': null,
                      'is_ongoing': true,
                    },
                  ]),
                  200,
                );
              case '/api/v1/education/':
                return http.Response(
                  jsonEncode([
                    {
                      'id': 7,
                      'school_name': 'Universitas Indonesia',
                      'period': '2024 - Sekarang',
                      'detail': 'S1 Ilmu Komputer',
                      'start_year': 2024,
                    },
                  ]),
                  200,
                );
              case '/api/v1/skills/':
                return http.Response(
                  jsonEncode([
                    {
                      'id': 'skill-1',
                      'title': 'Flutter',
                      'description': 'UI lintas platform.',
                      'level': 'Intermediate',
                      'code_snippet': 'void main() {}',
                    },
                  ]),
                  200,
                );
              case '/api/v1/techstacks/':
                return http.Response(
                  jsonEncode([
                    {
                      'id': 3,
                      'name': 'Django',
                      'icon_url': 'https://cdn.example.com/django.svg',
                      'filename': 'views.py',
                      'code_snippet': 'def index():\n    pass',
                      'order': 1,
                    },
                  ]),
                  200,
                );
              default:
                return http.Response('Not found', 404);
            }
          }),
        );

        final experiences = await client.getExperiences();
        final educations = await client.getEducations();
        final skills = await client.getSkills();
        final techStacks = await client.getTechStacks();

        expect(seenRequests, [
          'GET /api/v1/experiences/',
          'GET /api/v1/education/',
          'GET /api/v1/skills/',
          'GET /api/v1/techstacks/',
        ]);
        expect(experiences, hasLength(1));
        expect(experiences.first.id, 'exp-1');
        expect(experiences.first.startedAt, DateTime(2025, 6, 1));
        expect(experiences.first.isOngoing, isTrue);

        expect(educations, hasLength(1));
        expect(educations.first.id, 7);
        expect(educations.first.schoolName, 'Universitas Indonesia');

        expect(skills, hasLength(1));
        expect(skills.first.id, 'skill-1');
        expect(skills.first.level, 'Intermediate');

        expect(techStacks, hasLength(1));
        expect(techStacks.first.id, 3);
        expect(techStacks.first.codeSnippet, 'def index():\n    pass');
      },
    );

    test(
      'POST endpoints send Token auth, omit id, and parse created models',
      () async {
        final capturedBodies = <String, Map<String, dynamic>>{};
        final client = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.headers['Authorization'], 'Token secret-token');
            expect(
              request.headers['Content-Type'],
              'application/json; charset=UTF-8',
            );

            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body.containsKey('id'), isFalse);
            capturedBodies[request.url.path] = body;

            switch (request.url.path) {
              case '/api/v1/experiences/':
                return http.Response(
                  jsonEncode({...body, 'id': 'exp-created'}),
                  201,
                );
              case '/api/v1/education/':
                return http.Response(jsonEncode({...body, 'id': 15}), 201);
              case '/api/v1/skills/':
                return http.Response(
                  jsonEncode({...body, 'id': 'skill-created'}),
                  201,
                );
              case '/api/v1/techstacks/':
                return http.Response(jsonEncode({...body, 'id': 9}), 201);
              default:
                return http.Response('Not found', 404);
            }
          }),
        );

        final createdExp = await client.createExperience(
          Experience(
            id: 'client-ignored-id',
            title: 'Backend Intern',
            company: 'Acme',
            description: 'Membangun REST API.',
            category: 'internship',
            startedAt: DateTime(2025, 2, 1),
            endedAt: DateTime(2025, 8, 31),
          ),
          token: 'secret-token',
        );
        final createdEdu = await client.createEducation(
          const Education(
            id: 999,
            schoolName: 'Universitas Indonesia',
            period: '2024 - 2028',
            detail: 'Ilmu Komputer',
            startYear: 2024,
          ),
          token: 'secret-token',
        );
        final createdSkill = await client.createSkill(
          const Skill(
            id: 'ignored-skill-id',
            title: 'Dart',
            description: 'Pemrograman mobile.',
            level: 'Advanced',
            codeSnippet: '  final x = 1;',
          ),
          token: 'secret-token',
        );
        final createdStack = await client.createTechStack(
          const TechStack(
            id: 999,
            name: 'Flutter',
            iconUrl: 'https://cdn.example.com/flutter.svg',
            filename: 'main.dart',
            codeSnippet: 'void main() {\n  runApp(app);\n}',
            order: 2,
          ),
          token: 'secret-token',
        );

        expect(createdExp.id, 'exp-created');
        expect(
          capturedBodies['/api/v1/experiences/']?['started_at'],
          '2025-02-01',
        );
        expect(
          capturedBodies['/api/v1/experiences/']?['ended_at'],
          '2025-08-31',
        );

        expect(createdEdu.id, 15);
        expect(capturedBodies['/api/v1/education/']?['start_year'], 2024);

        expect(createdSkill.id, 'skill-created');
        expect(capturedBodies['/api/v1/skills/']?['level'], 'Advanced');

        expect(createdStack.id, 9);
        expect(
          capturedBodies['/api/v1/techstacks/']?['code_snippet'],
          'void main() {\n  runApp(app);\n}',
        );
      },
    );

    test(
      'DELETE endpoints send authenticated DELETE requests across all models',
      () async {
        final deletedPaths = <String>[];
        final client = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((request) async {
            expect(request.method, 'DELETE');
            expect(request.headers['Authorization'], 'Token del-token');
            expect(request.headers['Accept'], 'application/json');
            deletedPaths.add(request.url.path);
            return http.Response('', 204);
          }),
        );

        await client.deleteProject('proj-1', token: 'del-token');
        await client.deleteExperience('exp-1', token: 'del-token');
        await client.deleteEducation(7, token: 'del-token');
        await client.deleteSkill('skill-1', token: 'del-token');
        await client.deleteTechStack(3, token: 'del-token');

        expect(deletedPaths, [
          '/api/v1/projects/proj-1/',
          '/api/v1/experiences/exp-1/',
          '/api/v1/education/7/',
          '/api/v1/skills/skill-1/',
          '/api/v1/techstacks/3/',
        ]);
      },
    );

    test('new portfolio endpoints handle malformed payloads, 400, 401, 500, and timeout', () async {
      final malformedListClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) async => http.Response('{"bad": true}', 200)),
      );
      await expectLater(
        malformedListClient.getExperiences(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 200)
              .having(
                (e) => e.message,
                'message',
                'Format respons daftar pengalaman tidak valid.',
              ),
        ),
      );
      await expectLater(
        malformedListClient.getEducations(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Format respons daftar pendidikan tidak valid.',
          ),
        ),
      );

      final malformedItemClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) async => http.Response('["not-a-map"]', 200)),
      );
      await expectLater(
        malformedItemClient.getSkills(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Data keahlian dari server tidak sesuai kontrak.',
          ),
        ),
      );
      await expectLater(
        malformedItemClient.getTechStacks(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Data tech stack dari server tidak sesuai kontrak.',
          ),
        ),
      );

      final malformedPostClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) async => http.Response('[]', 201)),
      );
      await expectLater(
        malformedPostClient.createEducation(
          const Education(
            schoolName: 'UI',
            period: '2024',
            detail: 'CS',
            startYear: 2024,
          ),
          token: 'tok',
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Format respons pendidikan tidak valid.',
          ),
        ),
      );

      final badRequestClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'ended_at': ['Ended date cannot be earlier than started date.'],
            }),
            400,
          ),
        ),
      );
      await expectLater(
        badRequestClient.createExperience(
          const Experience(title: 'Intern', description: 'Desc'),
          token: 'tok',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                'ended_at: Ended date cannot be earlier than started date.',
              ),
        ),
      );

      final unauthorizedClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode({'detail': 'Invalid token.'}), 401),
        ),
      );
      await expectLater(
        unauthorizedClient.createSkill(
          const Skill(title: 'Dart', description: 'Desc', level: 'Basic'),
          token: 'expired',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', 'Invalid token.'),
        ),
      );
      await expectLater(
        unauthorizedClient.deleteProject('proj-1', token: 'expired'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', 'Invalid token.'),
        ),
      );

      final serverErrorClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient(
          (_) async => http.Response(
            '<html><body>500 Error</body></html>',
            500,
            reasonPhrase: 'Internal Server Error',
          ),
        ),
      );
      await expectLater(
        serverErrorClient.deleteTechStack(3, token: 'tok'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having(
                (e) => e.message,
                'message',
                'Permintaan gagal (HTTP 500: Internal Server Error).',
              ),
        ),
      );

      final hangingClient = ApiClient(
        baseUrl: 'https://mock.local',
        client: MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(
        hangingClient.getExperiences(),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        hangingClient.createTechStack(
          const TechStack(
            name: 'Dart',
            iconUrl: 'https://example.com/dart.svg',
            filename: 'main.dart',
            codeSnippet: 'void main() {}',
          ),
          token: 'tok',
        ),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        hangingClient.deleteEducation(1, token: 'tok'),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('ApiClient lifecycle', () {
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
