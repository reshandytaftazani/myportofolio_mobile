import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/portfolio_detail_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/portfolio_refresh_notifier.dart';
import 'package:myportofolio_mobile/services/project_refresh_notifier.dart';
import 'package:myportofolio_mobile/widgets/portfolio_async_list_view.dart';
import 'package:myportofolio_mobile/widgets/project_item_card.dart';
import 'package:provider/provider.dart';

/// Widget daftar proyek yang mengambil data publik secara asinkron dari API DRF.
///
/// Merupakan pembungkus tipis di atas [PortfolioAsyncListView] yang menjaga
/// kompatibilitas penuh dengan [ProjectListViewState] dan [ProjectRefreshNotifier].
class ProjectListView extends StatefulWidget {
  final ApiClient? apiClient;

  const ProjectListView({super.key, this.apiClient});

  @override
  State<ProjectListView> createState() => ProjectListViewState();
}

/// State publik untuk [ProjectListView] agar dapat dipicu reload dari luar.
class ProjectListViewState extends State<ProjectListView> {
  final GlobalKey<PortfolioAsyncListViewState<Project>> _listKey =
      GlobalKey<PortfolioAsyncListViewState<Project>>();
  ProjectRefreshNotifier? _projectRefreshNotifier;

  @override
  void initState() {
    super.initState();
    _projectRefreshNotifier = _resolveProjectRefreshNotifier();
  }

  ProjectRefreshNotifier? _resolveProjectRefreshNotifier() {
    try {
      return context.read<ProjectRefreshNotifier>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// Memuat ulang daftar proyek dari API DRF.
  Future<void> reload() async {
    final state = _listKey.currentState;
    if (state != null) {
      await state.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortfolioAsyncListView<Project>(
      key: _listKey,
      apiClient: widget.apiClient,
      fetcher: (client) => client.getProjects(),
      errorTitle: 'Gagal memuat daftar proyek',
      emptyMessage: 'Belum ada proyek.',
      refreshTarget: PortfolioRefreshTarget.projects,
      refreshListenable: _projectRefreshNotifier,
      itemBuilder: (context, project) => ProjectItemCard(
        project: project,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PortfolioDetailPage.project(project),
          ),
        ),
      ),
    );
  }
}
