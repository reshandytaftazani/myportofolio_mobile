import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/portfolio_detail_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/project_refresh_notifier.dart';
import 'package:myportofolio_mobile/utils/api_error_formatter.dart';
import 'package:myportofolio_mobile/widgets/project_item_card.dart';
import 'package:provider/provider.dart';

/// Widget daftar proyek yang mengambil data publik secara asinkron dari API DRF.
class ProjectListView extends StatefulWidget {
  final ApiClient? apiClient;

  const ProjectListView({super.key, this.apiClient});

  @override
  State<ProjectListView> createState() => ProjectListViewState();
}

/// State publik untuk [ProjectListView] agar dapat dipicu reload dari luar.
class ProjectListViewState extends State<ProjectListView> {
  late ApiClient _apiClient;
  bool _ownsApiClient = false;
  late Future<List<Project>> _projectsFuture;
  List<Project>? _cachedProjects;
  ProjectRefreshNotifier? _refreshNotifier;

  @override
  void initState() {
    super.initState();
    _apiClient = _resolveApiClient();
    _refreshNotifier = _resolveRefreshNotifier();
    _refreshNotifier?.addListener(_handleExternalRefresh);
    _projectsFuture = _apiClient.getProjects();
  }

  @override
  void dispose() {
    _refreshNotifier?.removeListener(_handleExternalRefresh);
    if (_ownsApiClient) {
      _apiClient.close();
    }
    super.dispose();
  }

  ProjectRefreshNotifier? _resolveRefreshNotifier() {
    try {
      return context.read<ProjectRefreshNotifier>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  void _handleExternalRefresh() {
    if (!mounted) return;
    reload().catchError((Object _) {});
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

  /// Memuat ulang daftar proyek dari API DRF.
  Future<void> reload() async {
    final future = _apiClient.getProjects();
    // Pastikan error tidak dianggap unhandled sebelum FutureBuilder sempat subscribe.
    future.then<void>((_) {}, onError: (Object _) {});
    setState(() {
      _projectsFuture = future;
    });
    try {
      final projects = await future;
      if (mounted) {
        _cachedProjects = projects;
      }
    } catch (error) {
      if (!mounted) return;
      if (_cachedProjects != null) {
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

    return FutureBuilder<List<Project>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _cachedProjects = snapshot.data;
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData &&
            _cachedProjects == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError && _cachedProjects == null) {
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
                      'Gagal memuat daftar proyek',
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
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final projects = snapshot.data ?? _cachedProjects ?? const <Project>[];
        if (projects.isEmpty) {
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
                        'No projects found.',
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProjectItemCard(
                  project: project,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PortfolioDetailPage.project(project),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
