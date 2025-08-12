import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/edit_mode_provider.dart';

class EditableTextField extends StatefulWidget {
  final String initialValue;
  final Function(String) onSave;
  final TextStyle? style;
  final int maxLines;
  final String? hint;
  final bool isTitle;
  
  const EditableTextField({
    super.key,
    required this.initialValue,
    required this.onSave,
    this.style,
    this.maxLines = 1,
    this.hint,
    this.isTitle = false,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _save();
      }
    });
  }
  
  @override
  void didUpdateWidget(EditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _save() {
    if (_controller.text != widget.initialValue) {
      widget.onSave(_controller.text);
    }
    setState(() {
      _isEditing = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditMode = context.watch<EditModeProvider>().isEditMode;
    
    if (!isEditMode || !_isEditing) {
      return MouseRegion(
        cursor: isEditMode ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: isEditMode ? () {
            setState(() {
              _isEditing = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _focusNode.requestFocus();
            });
          } : null,
          child: Container(
            padding: isEditMode ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : null,
            decoration: isEditMode ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            ) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _controller.text.isEmpty ? (widget.hint ?? 'Click to edit') : _controller.text,
                    style: widget.style?.copyWith(
                      color: _controller.text.isEmpty && isEditMode 
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                        : widget.style?.color,
                    ) ?? TextStyle(
                      color: _controller.text.isEmpty && isEditMode 
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                        : null,
                    ),
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isEditMode) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: widget.isTitle ? 20 : 16,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: widget.style,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              onPressed: _save,
              color: Colors.green,
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                _controller.text = widget.initialValue;
                setState(() {
                  _isEditing = false;
                });
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
      onSubmitted: (_) => _save(),
    );
  }
}
