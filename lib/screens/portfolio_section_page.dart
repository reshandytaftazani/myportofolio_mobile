import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/services/project_refresh_notifier.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Konfigurasi aksi tambahan pada halaman bagian portofolio.
class SectionAction {
  /// Label tombol aksi.
  final String label;

  /// Ikon tombol aksi.
  final IconData icon;

  /// Builder halaman tujuan saat tombol ditekan.
  final WidgetBuilder builder;

  /// Menandakan apakah aksi ini membutuhkan pengguna login terlebih dahulu.
  final bool requiresAuth;

  /// Membuat instansi [SectionAction].
  const SectionAction({
    required this.label,
    required this.icon,
    required this.builder,
    this.requiresAuth = false,
  });
}

/// Halaman bagian portofolio yang menyatukan tampilan daftar dan tombol tambah.
///
/// Menampilkan daftar item menggunakan [ListView.builder] atau fallback ke
/// tampilan kosong bila daftar belum memiliki data. Mendukung tab sekunder
/// (misalnya tab Tech Stack pada bagian Projects) dengan tombol tambah (FAB)
/// yang menyesuaikan tab aktif.
class PortfolioSectionPage extends StatefulWidget {
  /// Identitas stabil bagian portofolio ini.
  final PortfolioSection section;

  /// Judul bagian pada AppBar.
  final String title;

  /// Deskripsi singkat saat daftar masih kosong.
  final String emptyMessage;

  /// Ikon representatif untuk bagian ini.
  final IconData icon;

  /// Warna aksen bagian ini.
  final Color accentColor;

  /// Aksi utama untuk menambah data pada bagian ini.
  final SectionAction primaryAction;

  /// Aksi sekunder opsional (misalnya Tambah Tech Stack pada bagian Proyek).
  final SectionAction? secondaryAction;

  /// Jumlah item pada daftar utama.
  final int itemCount;

  /// Builder item untuk daftar utama.
  final IndexedWidgetBuilder? itemBuilder;

  /// Label tab utama saat tab sekunder diaktifkan.
  final String? primaryTabLabel;

  /// Label tab sekunder opsional (misalnya "Tech Stack").
  final String? secondaryTabLabel;

  /// Jumlah item pada daftar tab sekunder.
  final int secondaryItemCount;

  /// Builder item untuk daftar tab sekunder.
  final IndexedWidgetBuilder? secondaryItemBuilder;

  /// Konten kustom opsional untuk tab utama (mis. [ProjectListView]).
  final Widget? primaryBody;

  /// Callback opsional setelah [primaryAction] selesai dijalankan.
  final Future<void>? Function()? onPrimaryActionSuccess;

  /// Membuat instansi [PortfolioSectionPage].
  const PortfolioSectionPage({
    super.key,
    required this.section,
    required this.title,
    required this.emptyMessage,
    required this.icon,
    required this.accentColor,
    required this.primaryAction,
    this.secondaryAction,
    this.itemCount = 0,
    this.itemBuilder,
    this.primaryTabLabel,
    this.secondaryTabLabel,
    this.secondaryItemCount = 0,
    this.secondaryItemBuilder,
    this.primaryBody,
    this.onPrimaryActionSuccess,
  });

  @override
  State<PortfolioSectionPage> createState() => _PortfolioSectionPageState();
}

class _PortfolioSectionPageState extends State<PortfolioSectionPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _activeTabIndex = 0;

  bool get _hasTabs => widget.secondaryTabLabel != null;

  SectionAction get _activeAction {
    if (_activeTabIndex == 1 && widget.secondaryAction != null) {
      return widget.secondaryAction!;
    }
    return widget.primaryAction;
  }

  @override
  void initState() {
    super.initState();
    _syncTabController();
  }

  @override
  void didUpdateWidget(covariant PortfolioSectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secondaryTabLabel != widget.secondaryTabLabel) {
      _syncTabController();
    }
  }

  void _syncTabController() {
    _tabController?.removeListener(_handleTabChanged);
    _tabController?.dispose();
    _tabController = null;
    _activeTabIndex = 0;

    if (_hasTabs) {
      _tabController = TabController(length: 2, vsync: this)
        ..addListener(_handleTabChanged);
    }
  }

  void _handleTabChanged() {
    final controller = _tabController;
    if (controller == null) return;
    if (controller.index != _activeTabIndex) {
      setState(() {
        _activeTabIndex = controller.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _openAction(BuildContext context, SectionAction action) async {
    if (action.requiresAuth) {
      final loggedIn = await ensureLoggedIn(context);
      if (!loggedIn || !context.mounted) return;
    }

    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(builder: action.builder),
    );
    if (!context.mounted) return;
    if (action == widget.primaryAction && result == true) {
      if (widget.onPrimaryActionSuccess != null) {
        await widget.onPrimaryActionSuccess!.call();
      } else if (widget.section == PortfolioSection.projects) {
        try {
          context.read<ProjectRefreshNotifier>().requestRefresh();
        } on ProviderNotFoundException {
          // Abaikan jika tidak ada ProjectRefreshNotifier di widget tree.
        }
      }
    }
  }

  Widget _buildListOrEmpty({
    required BuildContext context,
    required int count,
    required IndexedWidgetBuilder? builder,
    required String emptyTitle,
    required SectionAction emptyPrimaryAction,
    required SectionAction? emptySecondaryAction,
  }) {
    if (count == 0 || builder == null) {
      return _EmptySectionView(
        title: emptyTitle,
        emptyMessage: widget.emptyMessage,
        icon: widget.icon,
        accentColor: widget.accentColor,
        primaryAction: emptyPrimaryAction,
        secondaryAction: emptySecondaryAction,
        onOpenAction: (action) => _openAction(context, action),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: builder(context, index),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!_hasTabs) {
      if (widget.primaryBody != null) {
        return widget.primaryBody!;
      }
      return _buildListOrEmpty(
        context: context,
        count: widget.itemCount,
        builder: widget.itemBuilder,
        emptyTitle: 'Belum ada data ${widget.title}',
        emptyPrimaryAction: widget.primaryAction,
        emptySecondaryAction: widget.secondaryAction,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        Column(
          children: [
            if (widget.secondaryAction != null &&
                (widget.primaryBody != null || widget.itemCount > 0))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _openAction(context, widget.secondaryAction!),
                    icon: Icon(widget.secondaryAction!.icon, size: 18),
                    label: Text(widget.secondaryAction!.label),
                  ),
                ),
              ),
            Expanded(
              child:
                  widget.primaryBody ??
                  _buildListOrEmpty(
                    context: context,
                    count: widget.itemCount,
                    builder: widget.itemBuilder,
                    emptyTitle:
                        'Belum ada data ${widget.primaryTabLabel ?? widget.title}',
                    emptyPrimaryAction: widget.primaryAction,
                    emptySecondaryAction: widget.secondaryAction,
                  ),
            ),
          ],
        ),
        _buildListOrEmpty(
          context: context,
          count: widget.secondaryItemCount,
          builder: widget.secondaryItemBuilder,
          emptyTitle: 'Belum ada data ${widget.secondaryTabLabel}',
          emptyPrimaryAction: widget.secondaryAction ?? widget.primaryAction,
          emptySecondaryAction: null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeAction = _activeAction;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: _hasTabs
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: widget.primaryTabLabel ?? widget.title),
                  Tab(text: widget.secondaryTabLabel!),
                ],
              )
            : null,
      ),
      drawer: LeftDrawer(activeSection: widget.section),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAction(context, activeAction),
        icon: Icon(activeAction.icon),
        label: Text(activeAction.label),
      ),
    );
  }
}

class _EmptySectionView extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final IconData icon;
  final Color accentColor;
  final SectionAction primaryAction;
  final SectionAction? secondaryAction;
  final ValueChanged<SectionAction> onOpenAction;

  const _EmptySectionView({
    required this.title,
    required this.emptyMessage,
    required this.icon,
    required this.accentColor,
    required this.primaryAction,
    required this.secondaryAction,
    required this.onOpenAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48.0, color: accentColor),
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                emptyMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => onOpenAction(primaryAction),
                    icon: Icon(primaryAction.icon),
                    label: Text(primaryAction.label),
                  ),
                  if (secondaryAction != null)
                    OutlinedButton.icon(
                      onPressed: () => onOpenAction(secondaryAction!),
                      icon: Icon(secondaryAction!.icon),
                      label: Text(secondaryAction!.label),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
