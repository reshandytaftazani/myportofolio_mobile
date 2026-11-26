import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/portfolio_refresh_notifier.dart';
import 'package:myportofolio_mobile/widgets/portfolio_async_list_view.dart';
import 'package:provider/provider.dart';

void main() {
  group('PortfolioRefreshNotifier', () {
    test('tracks versions independently per target', () {
      final notifier = PortfolioRefreshNotifier();
      var notifications = 0;
      notifier.addListener(() => notifications++);

      expect(notifier.versionFor(PortfolioRefreshTarget.projects), 0);
      expect(notifier.versionFor(PortfolioRefreshTarget.techStacks), 0);
      expect(notifier.versionFor(PortfolioRefreshTarget.experiences), 0);
      expect(notifier.versionFor(PortfolioRefreshTarget.education), 0);
      expect(notifier.versionFor(PortfolioRefreshTarget.skills), 0);

      notifier.requestRefresh(PortfolioRefreshTarget.experiences);
      expect(notifier.versionFor(PortfolioRefreshTarget.experiences), 1);
      expect(notifier.versionFor(PortfolioRefreshTarget.projects), 0);
      expect(notifications, 1);

      notifier.requestSectionRefresh(PortfolioSection.skills);
      expect(notifier.versionFor(PortfolioRefreshTarget.skills), 1);
      expect(notifier.versionFor(PortfolioRefreshTarget.experiences), 1);
      expect(notifications, 2);

      notifier.requestRefreshAll();
      expect(notifier.versionFor(PortfolioRefreshTarget.projects), 1);
      expect(notifier.versionFor(PortfolioRefreshTarget.techStacks), 1);
      expect(notifier.versionFor(PortfolioRefreshTarget.experiences), 2);
      expect(notifier.versionFor(PortfolioRefreshTarget.education), 1);
      expect(notifier.versionFor(PortfolioRefreshTarget.skills), 2);
      expect(notifications, 3);
    });
  });

  group('PortfolioAsyncListView', () {
    testWidgets(
      'initializes future in initState and does not refetch on parent rebuild',
      (tester) async {
        var fetchCount = 0;
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((_) async => http.Response('[]', 200)),
        );

        Widget buildTree(int counter) {
          return Provider<ApiClient>.value(
            value: apiClient,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: Text('Count $counter')),
                body: PortfolioAsyncListView<String>(
                  fetcher: (_) async {
                    fetchCount++;
                    return const ['Alpha', 'Beta'];
                  },
                  errorTitle: 'Gagal memuat item',
                  emptyMessage: 'Belum ada item.',
                  itemBuilder: (_, item) => Text(item),
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(buildTree(1));
        await tester.pumpAndSettle();

        expect(find.text('Alpha'), findsOneWidget);
        expect(find.text('Beta'), findsOneWidget);
        expect(fetchCount, 1);

        await tester.pumpWidget(buildTree(2));
        await tester.pumpAndSettle();

        expect(find.text('Count 2'), findsOneWidget);
        expect(fetchCount, 1);
      },
    );

    testWidgets(
      'reloads only when its own PortfolioRefreshTarget is notified',
      (tester) async {
        var fetchCount = 0;
        final notifier = PortfolioRefreshNotifier();
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((_) async => http.Response('[]', 200)),
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ApiClient>.value(value: apiClient),
              ChangeNotifierProvider<PortfolioRefreshNotifier>.value(
                value: notifier,
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: PortfolioAsyncListView<String>(
                  fetcher: (_) async {
                    fetchCount++;
                    return ['Run $fetchCount'];
                  },
                  errorTitle: 'Gagal memuat pengalaman',
                  emptyMessage: 'Belum ada pengalaman.',
                  refreshTarget: PortfolioRefreshTarget.experiences,
                  itemBuilder: (_, item) => Text(item),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Run 1'), findsOneWidget);
        expect(fetchCount, 1);

        // Refreshing unrelated target must NOT trigger reload.
        notifier.requestRefresh(PortfolioRefreshTarget.skills);
        await tester.pumpAndSettle();
        expect(fetchCount, 1);
        expect(find.text('Run 1'), findsOneWidget);

        // Refreshing matching target MUST trigger reload.
        notifier.requestRefresh(PortfolioRefreshTarget.experiences);
        await tester.pumpAndSettle();
        expect(fetchCount, 2);
        expect(find.text('Run 2'), findsOneWidget);
      },
    );

    testWidgets(
      'shows loading, error with Retry, empty state with RefreshIndicator, and keeps cache on refresh failure',
      (tester) async {
        var attempt = 0;
        final initialCompleter = Completer<List<String>>();
        final apiClient = ApiClient(
          baseUrl: 'https://mock.local',
          client: MockClient((_) async => http.Response('[]', 200)),
        );

        await tester.pumpWidget(
          Provider<ApiClient>.value(
            value: apiClient,
            child: MaterialApp(
              home: Scaffold(
                body: PortfolioAsyncListView<String>(
                  fetcher: (_) async {
                    attempt++;
                    if (attempt == 1) {
                      return initialCompleter.future;
                    }
                    if (attempt == 2) {
                      return const <String>[];
                    }
                    if (attempt == 3) {
                      return const ['Loaded Item'];
                    }
                    throw const SocketException('Offline');
                  },
                  errorTitle: 'Gagal memuat data uji',
                  emptyMessage: 'Daftar uji kosong.',
                  itemBuilder: (_, item) => Text(item),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        initialCompleter.completeError(const SocketException('No internet'));
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat data uji'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Coba Lagi'));
        await tester.pumpAndSettle();

        expect(find.text('Daftar uji kosong.'), findsOneWidget);
        expect(find.byType(RefreshIndicator), findsOneWidget);

        // Pull-to-refresh from empty state -> loads item.
        await tester.fling(
          find.text('Daftar uji kosong.'),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        expect(find.text('Loaded Item'), findsOneWidget);

        // Pull-to-refresh failure -> keeps cached item and shows SnackBar.
        await tester.fling(
          find.text('Loaded Item'),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        expect(find.text('Loaded Item'), findsOneWidget);
        expect(find.textContaining('Gagal memuat ulang:'), findsOneWidget);
      },
    );
  });
}
