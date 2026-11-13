import 'package:flutter/material.dart';

/// Widget header visual profil pemilik portofolio.
///
/// Menampilkan avatar inisial, nama lengkap, bio peran singkat,
/// dan badge status aktif untuk memberikan identitas visual yang profesional.
class ProfileHeader extends StatelessWidget {
  /// Nama lengkap pemilik portofolio.
  final String name;

  /// Deskripsi peran atau keahlian singkat.
  final String role;

  /// Inisial dua huruf untuk avatar visual.
  final String initials;

  /// Membuat instansi [ProfileHeader].
  const ProfileHeader({
    super.key,
    required this.name,
    this.role = 'Computer Science Student • Web & Mobile Developer',
    this.initials = 'RT',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Avatar inisial dengan latar belakang warna tema
          CircleAvatar(
            radius: 26.0,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          // Informasi teks nama, peran, dan badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3.0),
                Text(
                  role,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),
                // Badge status aktif mahasiswa
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.green.shade600, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8.0,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Active Student',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
