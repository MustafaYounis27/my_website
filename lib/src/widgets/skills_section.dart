import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/section_header.dart';
import '../state/cv_provider.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Skills'),
        const SizedBox(height: 24),
        
        // Skills grid with enhanced design
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.03),
                Theme.of(context).colorScheme.secondary.withOpacity(0.03),
              ],
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.code_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Technical Stack',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (int i = 0; i < cv.skills.length; i++)
                          _SkillChip(
                            skill: cv.skills[i],
                            index: i,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.1, duration: 500.ms),
      ],
    );
  }
}

class _SkillChip extends StatefulWidget {
  final String skill;
  final int index;

  const _SkillChip({
    required this.skill,
    required this.index,
  });

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHovered
                ? [
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ]
                : [
                    Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.04),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                : Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(_isHovered ? 0.15 : 0.08),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForSkill(widget.skill),
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.skill,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: widget.index * 50))
      .slideY(begin: 0.2, duration: 400.ms, delay: Duration(milliseconds: widget.index * 50))
      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, delay: Duration(milliseconds: widget.index * 50));
  }
  
  IconData _getIconForSkill(String skill) {
    final lowerSkill = skill.toLowerCase();
    
    // Programming languages and frameworks
    if (lowerSkill.contains('flutter') || lowerSkill.contains('dart')) {
      return Icons.flutter_dash;
    } else if (lowerSkill.contains('react') || lowerSkill.contains('javascript')) {
      return Icons.javascript;
    } else if (lowerSkill.contains('python')) {
      return Icons.code;
    } else if (lowerSkill.contains('swift') || lowerSkill.contains('ios')) {
      return Icons.phone_iphone;
    } else if (lowerSkill.contains('kotlin') || lowerSkill.contains('android')) {
      return Icons.android;
    } else if (lowerSkill.contains('java')) {
      return Icons.coffee;
    } else if (lowerSkill.contains('c++') || lowerSkill.contains('c#')) {
      return Icons.memory;
    }
    
    // Cloud and DevOps
    else if (lowerSkill.contains('firebase') || lowerSkill.contains('aws') || 
             lowerSkill.contains('cloud')) {
      return Icons.cloud;
    } else if (lowerSkill.contains('docker') || lowerSkill.contains('kubernetes')) {
      return Icons.widgets;
    } else if (lowerSkill.contains('git')) {
      return Icons.account_tree;
    } else if (lowerSkill.contains('ci/cd')) {
      return Icons.autorenew;
    }
    
    // Databases
    else if (lowerSkill.contains('sql') || lowerSkill.contains('database') ||
             lowerSkill.contains('mongodb') || lowerSkill.contains('postgres')) {
      return Icons.storage;
    }
    
    // Design
    else if (lowerSkill.contains('figma') || lowerSkill.contains('sketch') ||
             lowerSkill.contains('ui') || lowerSkill.contains('ux')) {
      return Icons.palette;
    }
    
    // Default
    return Icons.star;
  }
}
