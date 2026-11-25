import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/widgets/portfolio_network_image.dart';

/// Kartu tampilan untuk satu entri [Experience] pada daftar portofolio.
class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final VoidCallback? onTap;

  const ExperienceCard({super.key, required this.experience, this.onTap});

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _formatDate(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  String _buildDateRangeText() {
    if (experience.startedAt == null && experience.endedAt == null) {
      return switch (experience.endStatus) {
        ExperienceEndStatus.ongoing => 'Ongoing',
        ExperienceEndStatus.completed ||
        ExperienceEndStatus.unknown => 'Tanggal belum diisi',
      };
    }
    final start = experience.startedAt != null
        ? _formatDate(experience.startedAt!)
        : 'Belum diisi';
    final end = switch (experience.endStatus) {
      ExperienceEndStatus.ongoing => 'Sekarang',
      ExperienceEndStatus.completed => _formatDate(experience.endedAt!),
      ExperienceEndStatus.unknown => 'Belum diisi',
    };
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasThumbnail =
        experience.thumbnail != null && experience.thumbnail!.isNotEmpty;
    final hasCompany =
        experience.company != null && experience.company!.trim().isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  child: hasThumbnail
                      ? PortfolioNetworkImage(
                          imageUrl: experience.thumbnail!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          fallbackBuilder: (_) =>
                              _buildThumbnailFallback(theme),
                        )
                      : _buildThumbnailFallback(theme),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            experience.categoryLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (experience.isOngoing)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Ongoing',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      experience.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasCompany) ...[
                      const SizedBox(height: 2),
                      Text(
                        experience.company!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _buildDateRangeText(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      experience.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailFallback(ThemeData theme) {
    return Icon(
      Icons.work_outline_rounded,
      color: theme.colorScheme.primary,
      size: 28,
    );
  }
}
