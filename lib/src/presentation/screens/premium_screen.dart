import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0x00000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppTheme.start, AppTheme.end],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PremiumBackgroundPainter()),
                ),
              ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Premium',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GlassPanel(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Unlock the fastest ClearBG workflow',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Go Premium and remove backgrounds without limits.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Choose a plan that fits your workflow and get the best export experience for creators, sellers, and everyday edits.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          GlassPanel(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose Your Plan',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 14),
                                _BillingToggle(
                                  isYearly: _isYearly,
                                  onChanged: (value) {
                                    setState(() {
                                      _isYearly = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 18),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final wide = constraints.maxWidth >= 760;
                                    final monthlyCard = _PlanCard(
                                      title: 'Monthly',
                                      price: '\$4.99',
                                      period: '/month',
                                      description:
                                          'Best for trying premium tools without a long commitment.',
                                      isActive: !_isYearly,
                                      badgeText: 'Flexible',
                                      accent: const Color(0xFF67E8F9),
                                    );
                                    final yearlyCard = _PlanCard(
                                      title: 'Yearly',
                                      price: '\$29.99',
                                      period: '/year',
                                      description:
                                          'Best value for frequent edits with lower per-month cost.',
                                      isActive: _isYearly,
                                      badgeText: 'Save 50%',
                                      accent: const Color(0xFF60A5FA),
                                    );

                                    if (!wide) {
                                      return Column(
                                        children: [
                                          monthlyCard,
                                          const SizedBox(height: 16),
                                          yearlyCard,
                                        ],
                                      );
                                    }

                                    final cardWidth =
                                        (constraints.maxWidth - 16) / 2;

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: cardWidth,
                                          child: monthlyCard,
                                        ),
                                        const SizedBox(width: 16),
                                        SizedBox(
                                          width: cardWidth,
                                          child: yearlyCard,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(56),
                                  ),
                                  child: Text(
                                    _isYearly
                                        ? 'Continue with Yearly'
                                        : 'Continue with Monthly',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          GlassPanel(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What You Get',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 14),
                                const _BenefitRow(
                                  title: 'Unlimited removals',
                                  subtitle:
                                      'Process as many images as you need without cooldowns.',
                                  icon: Icons.all_inclusive_rounded,
                                ),
                                const SizedBox(height: 12),
                                const _BenefitRow(
                                  title: 'Faster exports',
                                  subtitle:
                                      'Prioritized processing feel with cleaner workflow and fewer interruptions.',
                                  icon: Icons.flash_on_rounded,
                                ),
                                const SizedBox(height: 12),
                                const _BenefitRow(
                                  title: 'Premium backgrounds',
                                  subtitle:
                                      'Access richer background presets and custom styling options.',
                                  icon: Icons.wallpaper_rounded,
                                ),
                                const SizedBox(height: 12),
                                const _BenefitRow(
                                  title: 'High-quality PNG output',
                                  subtitle:
                                      'Export polished transparent cutouts ready for product shots and social posts.',
                                  icon: Icons.download_done_rounded,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.isYearly, required this.onChanged});

  final bool isYearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TogglePill(
              label: 'Monthly',
              isActive: !isYearly,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TogglePill(
              label: 'Yearly',
              isActive: isYearly,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF67E8F9), Color(0xFF60A5FA)],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isActive ? const Color(0xFF0F172A) : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.isActive,
    required this.badgeText,
    required this.accent,
  });

  final String title;
  final String price;
  final String period;
  final String description;
  final bool isActive;
  final String badgeText;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.10),
                ],
              )
            : null,
        color: isActive ? null : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isActive
              ? accent.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.12),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(
                  text: price,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: period,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF67E8F9), Color(0xFF60A5FA)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.78, size.height * 0.18),
              radius: size.width * 0.28,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.18),
      size.width * 0.28,
      glow,
    );

    final Paint secondGlow = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x4060A5FA), Color(0x0060A5FA)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.22, size.height * 0.78),
              radius: size.width * 0.26,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.78),
      size.width * 0.26,
      secondGlow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
