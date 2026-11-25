import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/portfolio_detail_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
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

  @override
  void initState() {
    super.initState();
    _apiClient = _resolveApiClient();
    _projectsFuture = _apiClient.getProjects();
  }

  @override
  void dispose() {
    if (_ownsApiClient) {
      _apiClient.close();
    }
    super.dispose();
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
  Future<void> reload() {
    final future = _apiClient.getProjects();
    setState(() {
      _projectsFuture = future;
    });
    return future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Project>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
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
                      onPressed: reload,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final projects = snapshot.data ?? const <Project>[];
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
