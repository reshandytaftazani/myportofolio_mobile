import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';
import 'package:myportofolio_mobile/widgets/portfolio_network_image.dart';

/// Kartu tampilan untuk satu entri [TechStack] beserta preview code block.
class TechStackCard extends StatelessWidget {
  final TechStack techStack;
  final VoidCallback? onTap;

  const TechStackCard({super.key, required this.techStack, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: techStack.iconUrl.isNotEmpty
                          ? PortfolioNetworkImage(
                              imageUrl: techStack.iconUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              fallbackBuilder: (_) => _buildIconFallback(theme),
                            )
                          : _buildIconFallback(theme),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          techStack.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          techStack.filename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  techStack.codeSnippet,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: const Color(0xFFE2E8F0),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconFallback(ThemeData theme) {
    return Icon(Icons.code_rounded, color: theme.colorScheme.primary, size: 22);
  }
}
