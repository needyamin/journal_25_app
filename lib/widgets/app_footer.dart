import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final footerColor = const Color(0xFF1A3667);
    final linkColor = Colors.white;

    return Container(
      color: footerColor,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with logo and title
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Scientific Journal',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Middle section with links
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _buildFooterLink(context, 'About', '/about', linkColor),
              _buildFooterLink(context, 'Journals', '/journals', linkColor),
              _buildFooterLink(context, 'Articles', '/articles', linkColor),
              _buildFooterLink(context, 'Editorial Board', '/editorial', linkColor),
              _buildFooterLink(context, 'Contact', '/contact', linkColor),
              _buildFooterLink(context, 'Privacy Policy', '/privacy', linkColor),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bottom copyright section
          Text(
            '© ${DateTime.now().year} Scientific Journal. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ISSN: 2023-5678',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooterLink(
    BuildContext context, 
    String title, 
    String route, 
    Color color
  ) {
    return InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 