import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/skill.dart';

/// Kartu tampilan untuk satu entri [Skill] pada daftar portofolio.
class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback? onTap;

  const SkillCard({super.key, required this.skill, this.onTap});

  Widget _buildTitle(ThemeData theme) {
    return Text(
      skill.title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLevelBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill.level,
        softWrap: true,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSnippet =
        skill.codeSnippet != null && skill.codeSnippet!.trim().isNotEmpty;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale =
                      MediaQuery.textScalerOf(context).scale(14.0) / 14.0;
                  final isCompact =
                      constraints.maxWidth < 280 || textScale >= 1.3;
                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(theme),
                        const SizedBox(height: 6),
                        _buildLevelBadge(theme),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildTitle(theme)),
                      const SizedBox(width: 8),
                      Flexible(child: _buildLevelBadge(theme)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                skill.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (hasSnippet) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    skill.codeSnippet!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: const Color(0xFFE2E8F0),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
