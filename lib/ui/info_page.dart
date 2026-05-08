import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Dynamic Animated AppBar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              centerTitle: true,
              title: Text(
                'Information',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.surface,
                          colorScheme.tertiaryContainer.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // Centered Logo with subtle shadow
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/eotc.jpg',
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                              // Fallback for missing assets during testing
                              errorBuilder: (ctx, _, __) => Icon(
                                  Icons.church,
                                  size: 50,
                                  color: colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), // Spacer for title
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Header
                  _buildAnimatedHeader(context),
                  
                  const SizedBox(height: 32),
                  
                  _buildModernCard(
                    context,
                    title: "Our Mission",
                    icon: Icons.auto_awesome_rounded,
                    content:
                        "Establishing a thriving open-source community dedicated to building high-quality digital products for the Ethiopian Orthodox Tewahedo Church. We believe in preserving our heritage through modern technology.",
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildQuoteCard(
                    context,
                    "“በእናንተ ዘንድ ያለ፥ በልቡ ጥበበኛ የሆነ ሁሉ መጥቶ እግዚአብሔር ያዘዘውን ሁሉ ያድርግ።”",
                    "— ዘጸ 35:10",
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    "DETAILED INFORMATION",
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoTile(
                    context,
                    Icons.history_edu_rounded,
                    "Preservation",
                    "We digitize and format spiritual texts to ensure they are accessible to everyone, anywhere, on any device.",
                  ),
                  _buildInfoTile(
                    context,
                    Icons.group_work_rounded,
                    "Open Source",
                    "All our projects are open for collaboration. We invite developers and designers to join our journey.",
                  ),
                  _buildInfoTile(
                    context,
                    Icons.security_rounded,
                    "Integrity",
                    "Maintaining the authenticity of religious texts while providing a modern reading experience.",
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Social Links Wrap
                  Center(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildSocialChip(
                          context,
                          Icons.telegram,
                          "Telegram",
                          "https://t.me/EOTCOpenSource",
                        ),
                        _buildSocialChip(
                          context,
                          Icons.code_rounded,
                          "GitHub",
                          "https://github.com/EOTCOpenSource",
                        ),
                        _buildSocialChip(
                          context,
                          Icons.language_rounded,
                          "Website",
                          "https://nehemiah-osc.org/",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Footer
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Text(
            "ማኅበረ ነህምያ",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Nehemiah Open Source Community",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(BuildContext context,
      {required String title, required IconData icon, required String content}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, String quote, String author) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.08),
                theme.colorScheme.secondary.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Icon(Icons.format_quote_rounded, color: Colors.grey, size: 32),
              Text(
                quote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                author,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChip(BuildContext context, IconData icon, String label, String url) {
    final theme = Theme.of(context);
    return ActionChip(
      onPressed: () => _launchUrl(context, url),
      avatar: Icon(icon, size: 18, color: theme.colorScheme.onPrimaryContainer),
      label: Text(label),
      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontSize: 13, 
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onPrimaryContainer
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 20),
        Text(
          "መዝሙረ ዳዊት",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Version 1.0.0",
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Made with ", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
            const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 14),
            Text(" by Nehemiah Community", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url')),
        );
      }
    }
  }
}
