import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/edit_mode_provider.dart';

class EditModeToggle extends StatelessWidget {
  const EditModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final editProvider = context.watch<EditModeProvider>();
    
    // Only show toggle if user is owner
    if (!editProvider.isOwner) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 24,
      right: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(28),
          color: editProvider.isEditMode 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => editProvider.toggleEditMode(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    editProvider.isEditMode ? Icons.save : Icons.edit,
                    size: 20,
                    color: editProvider.isEditMode
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    editProvider.isEditMode ? 'Save Mode' : 'Edit Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: editProvider.isEditMode
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 1, end: 0, duration: 300.ms),
    );
  }
}
