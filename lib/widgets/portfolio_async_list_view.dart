import 'dart:async' show unawaited;

import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/portfolio_refresh_notifier.dart';
import 'package:myportofolio_mobile/utils/api_error_formatter.dart';
import 'package:provider/provider.dart';

/// Fungsi pengambil daftar data bertipe [T] dari [ApiClient].
typedef PortfolioListFetcher<T> = Future<List<T>> Function(ApiClient apiClient);

/// Builder widget kartu untuk satu item bertipe [T].
typedef PortfolioItemBuilder<T> = Widget Function(BuildContext context, T item);

/// Widget daftar asinkron generik yang mengambil data dari API DRF.
///
/// Menginisialisasi [Future] di dalam [State.initState] (bukan di `build()`),
/// mendukung *pull-to-refresh* via [RefreshIndicator], mempertahankan data
/// cache saat refresh sedang berjalan atau gagal, serta menyediakan tampilan
/// loading, error dengan tombol **Coba Lagi**, dan keadaan kosong.
class PortfolioAsyncListView<T> extends StatefulWidget {
  /// Opsional [ApiClient] kustom; jika `null`, akan membaca dari [Provider]
  /// atau membuat instance internal yang otomatis ditutup saat `dispose()`.
  final ApiClient? apiClient;

  /// Callback pemanggil endpoint GET pada [ApiClient].
  final PortfolioListFetcher<T> fetcher;

  /// Builder tampilan untuk setiap item [T].
  final PortfolioItemBuilder<T> itemBuilder;

  /// Judul pesan error yang ditampilkan saat pemuatan awal gagal.
  final String errorTitle;

  /// Pesan ramah saat daftar yang diterima dari server kosong.
  final String emptyMessage;

  /// Target refresh opsional yang didengarkan melalui [PortfolioRefreshNotifier].
  final PortfolioRefreshTarget? refreshTarget;

  /// [Listenable] tambahan opsional untuk memicu reload (mis. notifier legacy).
  final Listenable? refreshListenable;

  /// Padding daftar item.
  final EdgeInsetsGeometry padding;

  /// Jarak vertikal antar item pada daftar.
  final double itemSpacing;

  const PortfolioAsyncListView({
    super.key,
    this.apiClient,
    required this.fetcher,
    required this.itemBuilder,
    required this.errorTitle,
    required this.emptyMessage,
    this.refreshTarget,
    this.refreshListenable,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 88),
    this.itemSpacing = 12,
  });

  @override
  State<PortfolioAsyncListView<T>> createState() =>
      PortfolioAsyncListViewState<T>();
}

/// State publik untuk [PortfolioAsyncListView] agar dapat dipicu reload dari luar.
class PortfolioAsyncListViewState<T> extends State<PortfolioAsyncListView<T>> {
  late ApiClient _apiClient;
  bool _ownsApiClient = false;
  late Future<List<T>> _itemsFuture;
  List<T>? _cachedItems;
  PortfolioRefreshNotifier? _portfolioRefreshNotifier;
  int _lastRefreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = _resolveApiClient();
    _attachPortfolioRefreshNotifier();
    widget.refreshListenable?.addListener(_handleExternalRefresh);
    _itemsFuture = widget.fetcher(_apiClient);
  }

  @override
  void didUpdateWidget(covariant PortfolioAsyncListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshListenable != widget.refreshListenable) {
      oldWidget.refreshListenable?.removeListener(_handleExternalRefresh);
      widget.refreshListenable?.addListener(_handleExternalRefresh);
    }
    if (oldWidget.refreshTarget != widget.refreshTarget) {
      _detachPortfolioRefreshNotifier();
      _attachPortfolioRefreshNotifier();
    }
  }

  @override
  void dispose() {
    _detachPortfolioRefreshNotifier();
    widget.refreshListenable?.removeListener(_handleExternalRefresh);
    if (_ownsApiClient) {
      _apiClient.close();
    }
    super.dispose();
  }

  void _attachPortfolioRefreshNotifier() {
    final target = widget.refreshTarget;
    if (target == null) return;
    try {
      final notifier = context.read<PortfolioRefreshNotifier>();
      _portfolioRefreshNotifier = notifier;
      _lastRefreshVersion = notifier.versionFor(target);
      notifier.addListener(_handlePortfolioRefresh);
    } on ProviderNotFoundException {
      _portfolioRefreshNotifier = null;
      _lastRefreshVersion = 0;
    }
  }

  void _detachPortfolioRefreshNotifier() {
    _portfolioRefreshNotifier?.removeListener(_handlePortfolioRefresh);
    _portfolioRefreshNotifier = null;
  }

  void _handlePortfolioRefresh() {
    if (!mounted) return;
    final target = widget.refreshTarget;
    final notifier = _portfolioRefreshNotifier;
    if (target == null || notifier == null) return;
    final currentVersion = notifier.versionFor(target);
    if (currentVersion == _lastRefreshVersion) return;
    _lastRefreshVersion = currentVersion;
    unawaited(reload().catchError((Object _) {}));
  }

  void _handleExternalRefresh() {
    if (!mounted) return;
    unawaited(reload().catchError((Object _) {}));
  }

  ApiClient _resolveApiClient() {
    if (widget.apiClient != null) {
      _ownsApiClient = false;
      return widget.apiClient!;
    }
    try {
      final provided = context.read<ApiClient>();
      _ownsApiClient = false;
      return provided;
    } on ProviderNotFoundException {
      _ownsApiClient = true;
      return ApiClient();
    }
  }

  /// Memuat ulang daftar data dari API DRF.
  Future<void> reload() async {
    final future = widget.fetcher(_apiClient);
    // Pastikan error tidak dianggap unhandled sebelum FutureBuilder sempat subscribe.
    unawaited(future.then<void>((_) {}, onError: (Object _) {}));
    setState(() {
      _itemsFuture = future;
    });
    try {
      final items = await future;
      if (mounted) {
        _cachedItems = items;
      }
    } catch (error) {
      if (!mounted) return;
      if (_cachedItems != null) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.hideCurrentSnackBar();
        messenger?.showSnackBar(
          SnackBar(
            content: Text('Gagal memuat ulang: ${formatApiError(error)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<T>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _cachedItems = snapshot.data;
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData &&
            _cachedItems == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError && _cachedItems == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.errorTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatApiError(snapshot.error ?? 'Unknown error'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        try {
                          await reload();
                        } catch (_) {
                          // Error sudah ditampilkan oleh FutureBuilder melalui snapshot.error.
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final items = snapshot.data ?? _cachedItems ?? <T>[];
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: reload,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.emptyMessage,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: reload,
          child: ListView.builder(
            padding: widget.padding,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(bottom: widget.itemSpacing),
                child: widget.itemBuilder(context, item),
              );
            },
          ),
        );
      },
    );
  }
}
