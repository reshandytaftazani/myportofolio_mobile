import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';
import 'package:myportofolio_mobile/utils/url_launcher_helper.dart';
import 'package:myportofolio_mobile/widgets/code_snippet_box.dart';
import 'package:myportofolio_mobile/widgets/portfolio_network_image.dart';

/// Halaman detail lengkap untuk menampilkan seluruh atribut item portofolio.
class PortfolioDetailPage extends StatelessWidget {
  final String pageTitle;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color accentColor;
  final List<DetailBadge> badges;
  final String bodyText;
  final List<DetailRow> metadataRows;
  final String? codeSnippet;
  final String? codeFilename;
  final int starCount;
  final bool isStarred;
  final String starredByNames;

  const PortfolioDetailPage._({
    super.key,
    required this.pageTitle,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.fallbackIcon,
    required this.accentColor,
    required this.badges,
    required this.bodyText,
    required this.metadataRows,
    this.codeSnippet,
    this.codeFilename,
    required this.starCount,
    required this.isStarred,
    required this.starredByNames,
  });

  /// Membuat halaman detail untuk entri [Project].
  factory PortfolioDetailPage.project(Project project, {Key? key}) {
    return PortfolioDetailPage._(
      key: key,
      pageTitle: 'Detail Proyek',
      title: project.title,
      subtitle: project.techStack,
      imageUrl: project.projectImageUrl,
      fallbackIcon: Icons.folder_special_rounded,
      accentColor: Colors.indigo,
      badges: [
        DetailBadge(label: project.category),
        if (project.isFeatured)
          const DetailBadge(
            label: 'Featured',
            icon: Icons.star_rounded,
            isHighlighted: true,
          ),
      ],
      bodyText: project.description,
      metadataRows: [
        if (project.id != null) DetailRow(label: 'ID', value: project.id!),
        if (project.techStack.trim().isNotEmpty)
          DetailRow(label: 'Tech Stack', value: project.techStack),
        if (project.projectUrl.trim().isNotEmpty)
          DetailRow(
            label: 'URL Proyek',
            value: project.projectUrl,
            isLink: true,
          ),
        if (project.projectImageUrl.trim().isNotEmpty)
          DetailRow(label: 'URL Gambar', value: project.projectImageUrl),
        DetailRow(
          label: 'Status Unggulan',
          value: project.isFeatured ? 'Featured' : 'Reguler',
        ),
      ],
      starCount: project.starCount,
      isStarred: project.isStarred,
      starredByNames: project.starredByNames,
    );
  }

  /// Membuat halaman detail untuk entri [TechStack].
  factory PortfolioDetailPage.techStack(TechStack techStack, {Key? key}) {
    return PortfolioDetailPage._(
      key: key,
      pageTitle: 'Detail Tech Stack',
      title: techStack.name,
      subtitle: techStack.filename,
      imageUrl: techStack.iconUrl,
      fallbackIcon: Icons.layers_rounded,
      accentColor: Colors.indigo,
      badges: [DetailBadge(label: 'Order #${techStack.order}')],
      bodyText: 'Contoh implementasi kode pada berkas ${techStack.filename}.',
      metadataRows: [
        if (techStack.id != null)
          DetailRow(label: 'ID', value: techStack.id.toString()),
        DetailRow(label: 'Nama File', value: techStack.filename),
        DetailRow(label: 'Urutan Tampil', value: techStack.order.toString()),
        if (techStack.iconUrl.trim().isNotEmpty)
          DetailRow(label: 'URL Ikon', value: techStack.iconUrl),
      ],
      codeSnippet: techStack.codeSnippet,
      codeFilename: techStack.filename,
      starCount: techStack.starCount,
      isStarred: techStack.isStarred,
      starredByNames: techStack.starredByNames,
    );
  }

  /// Membuat halaman detail untuk entri [Experience].
  factory PortfolioDetailPage.experience(Experience experience, {Key? key}) {
    final startText = experience.startedAt != null
        ? _formatFullDate(experience.startedAt!)
        : 'Belum diisi';
    final endText = switch (experience.endStatus) {
      ExperienceEndStatus.ongoing => 'Sekarang (Ongoing)',
      ExperienceEndStatus.completed => _formatFullDate(experience.endedAt!),
      ExperienceEndStatus.unknown => 'Belum diisi',
    };

    return PortfolioDetailPage._(
      key: key,
      pageTitle: 'Detail Pengalaman',
      title: experience.title,
      subtitle: experience.company,
      imageUrl: experience.thumbnail,
      fallbackIcon: Icons.work_outline_rounded,
      accentColor: const Color(0xFF0277BD),
      badges: [
        DetailBadge(label: experience.categoryLabel),
        if (experience.isOngoing)
          const DetailBadge(
            label: 'Ongoing',
            icon: Icons.timelapse_rounded,
            isHighlighted: true,
          ),
      ],
      bodyText: experience.description,
      metadataRows: [
        if (experience.id != null)
          DetailRow(label: 'ID', value: experience.id!),
        if (experience.company != null && experience.company!.trim().isNotEmpty)
          DetailRow(
            label: 'Perusahaan / Organisasi',
            value: experience.company!,
          ),
        DetailRow(label: 'Kategori', value: experience.categoryLabel),
        DetailRow(label: 'Tanggal Mulai', value: startText),
        DetailRow(label: 'Tanggal Selesai', value: endText),
        if (experience.thumbnail != null &&
            experience.thumbnail!.trim().isNotEmpty)
          DetailRow(label: 'URL Thumbnail', value: experience.thumbnail!),
      ],
      starCount: experience.starCount,
      isStarred: experience.isStarred,
      starredByNames: experience.starredByNames,
    );
  }

  /// Membuat halaman detail untuk entri [Education].
  factory PortfolioDetailPage.education(Education education, {Key? key}) {
    return PortfolioDetailPage._(
      key: key,
      pageTitle: 'Detail Pendidikan',
      title: education.schoolName,
      subtitle: education.period,
      fallbackIcon: Icons.school_rounded,
      accentColor: const Color(0xFF00695C),
      badges: [DetailBadge(label: 'Mulai ${education.startYear}')],
      bodyText: education.detail,
      metadataRows: [
        if (education.id != null)
          DetailRow(label: 'ID', value: education.id.toString()),
        DetailRow(label: 'Institusi', value: education.schoolName),
        DetailRow(label: 'Periode', value: education.period),
        DetailRow(label: 'Tahun Mulai', value: education.startYear.toString()),
      ],
      starCount: education.starCount,
      isStarred: education.isStarred,
      starredByNames: education.starredByNames,
    );
  }

  /// Membuat halaman detail untuk entri [Skill].
  factory PortfolioDetailPage.skill(Skill skill, {Key? key}) {
    return PortfolioDetailPage._(
      key: key,
      pageTitle: 'Detail Keahlian',
      title: skill.title,
      fallbackIcon: Icons.code_rounded,
      accentColor: const Color(0xFF6A1B9A),
      badges: [DetailBadge(label: skill.level)],
      bodyText: skill.description,
      metadataRows: [
        if (skill.id != null) DetailRow(label: 'ID', value: skill.id!),
        DetailRow(label: 'Tingkat Kemahiran', value: skill.level),
      ],
      codeSnippet: skill.codeSnippet,
      starCount: skill.starCount,
      isStarred: skill.isStarred,
      starredByNames: skill.starredByNames,
    );
  }

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String _formatFullDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final hasCode = codeSnippet != null && codeSnippet!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: accentColor.withValues(alpha: 0.1),
                  child: PortfolioNetworkImage(
                    imageUrl: imageUrl!,
                    height: 160,
                    fit: isSvgImageUrl(imageUrl!)
                        ? BoxFit.contain
                        : BoxFit.cover,
                    fallbackBuilder: (_) => _buildBannerFallback(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (badges.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges.map((badge) {
                  final bgColor = badge.isHighlighted
                      ? Colors.amber.shade100
                      : accentColor.withValues(alpha: 0.12);
                  final fgColor = badge.isHighlighted
                      ? Colors.amber.shade900
                      : accentColor;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badge.icon != null) ...[
                          Icon(badge.icon, size: 15, color: fgColor),
                          const SizedBox(width: 5),
                        ],
                        Flexible(
                          child: Text(
                            badge.label,
                            softWrap: true,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: fgColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              bodyText,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            if (hasCode) ...[
              const SizedBox(height: 20),
              Text(
                codeFilename != null
                    ? 'Code Snippet ($codeFilename)'
                    : 'Code Snippet',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CodeSnippetBox(
                code: codeSnippet!,
                selectable: true,
                padding: const EdgeInsets.all(14),
                borderRadius: 12,
                lineHeight: 1.5,
              ),
            ],
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Lengkap',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...metadataRows.map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textScale =
                                MediaQuery.textScalerOf(context).scale(14.0) /
                                14.0;
                            final isCompact =
                                constraints.maxWidth < 260 || textScale >= 1.3;
                            final labelWidget = Text(
                              row.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                            final valueWidget = row.isLink
                                ? Semantics(
                                    link: true,
                                    label: 'Buka ${row.label} ${row.value}',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(6),
                                      onTap: () =>
                                          launchExternalUrl(context, row.value),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 44,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  row.value,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.open_in_new_rounded,
                                                size: 14,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SelectableText(
                                    row.value,
                                    style: theme.textTheme.bodySmall,
                                  );

                            if (isCompact) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  labelWidget,
                                  const SizedBox(height: 2),
                                  valueWidget,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 130, child: labelWidget),
                                Expanded(child: valueWidget),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Icon(
                          isStarred
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: isStarred
                              ? Colors.amber.shade700
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            starredByNames.trim().isNotEmpty
                                ? '$starCount bintang (oleh: $starredByNames)'
                                : '$starCount bintang',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerFallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        size: 56,
        color: accentColor.withValues(alpha: 0.7),
      ),
    );
  }
}

class DetailBadge {
  final String label;
  final IconData? icon;
  final bool isHighlighted;

  const DetailBadge({
    required this.label,
    this.icon,
    this.isHighlighted = false,
  });
}

class DetailRow {
  final String label;
  final String value;
  final bool isLink;

  const DetailRow({
    required this.label,
    required this.value,
    this.isLink = false,
  });
}
