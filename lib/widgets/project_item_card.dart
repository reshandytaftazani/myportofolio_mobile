import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/utils/url_launcher_helper.dart';
import 'package:myportofolio_mobile/widgets/portfolio_network_image.dart';

/// Kartu tampilan ringkas untuk satu entri [Project] pada daftar portofolio.
class ProjectItemCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectItemCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = project.projectImageUrl.isNotEmpty;
    final hasUrl = project.projectUrl.isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              SizedBox(
                height: 150,
                width: double.infinity,
                child: PortfolioNetworkImage(
                  imageUrl: project.projectImageUrl,
                  height: 150,
                  fit: BoxFit.cover,
                  fallbackBuilder: (_) => _buildImageFallback(theme),
                ),
              )
            else
              _buildImageFallback(theme),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _BadgeChip(
                        label: project.category,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                      if (project.isFeatured)
                        _BadgeChip(
                          label: 'Featured',
                          icon: Icons.star_rounded,
                          backgroundColor: Colors.amber.shade100,
                          foregroundColor: Colors.amber.shade900,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasUrl) ...[
                    const SizedBox(height: 8),
                    Semantics(
                      link: true,
                      label: 'Buka tautan proyek ${project.projectUrl}',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () =>
                            launchExternalUrl(context, project.projectUrl),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    project.projectUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback(ThemeData theme) {
    return Container(
      height: 110,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Center(
        child: Icon(
          Icons.folder_special_rounded,
          size: 40,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _BadgeChip({
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
