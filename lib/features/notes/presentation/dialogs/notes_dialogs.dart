import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';

class NotesActionSheetItem<T> {
  const NotesActionSheetItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? color;
}

class NotesSelectionDialogItem<T> {
  const NotesSelectionDialogItem({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

Future<String?> showNotesTextPromptDialog(
  BuildContext context, {
  required String title,
  required String hintText,
  required String confirmLabel,
  String? initialValue,
  bool multiline = false,
  SpeechController? speech,
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => _NotesTextPromptDialog(
      title: title,
      hintText: hintText,
      confirmLabel: confirmLabel,
      initialValue: initialValue,
      multiline: multiline,
      speech: speech,
    ),
  );

  final trimmed = result?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

class _NotesTextPromptDialog extends StatefulWidget {
  const _NotesTextPromptDialog({
    required this.title,
    required this.hintText,
    required this.confirmLabel,
    required this.initialValue,
    required this.multiline,
    required this.speech,
  });

  final String title;
  final String hintText;
  final String confirmLabel;
  final String? initialValue;
  final bool multiline;
  final SpeechController? speech;

  @override
  State<_NotesTextPromptDialog> createState() => _NotesTextPromptDialogState();
}

class _NotesTextPromptDialogState extends State<_NotesTextPromptDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _close([String? value]) {
    _focusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        widget.title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: widget.multiline ? 4 : 1,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: widget.hintText,
          suffixIcon: widget.speech == null
              ? null
              : SpeechMicButton(
                  controller: _controller,
                  speech: widget.speech!,
                  appendToExistingText: false,
                  onError: (message) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  ),
                ),
        ),
        onTapOutside: (_) => _focusNode.unfocus(),
        onSubmitted: widget.multiline ? null : (value) => _close(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: _close,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _close(_controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

Future<T?> showNotesActionSheet<T>(
  BuildContext context, {
  required List<NotesActionSheetItem<T>> actions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.surface,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions
              .map(
                (action) => ListTile(
                  leading: action.icon == null
                      ? null
                      : Icon(action.icon, color: action.color ?? AppColors.textPrimary),
                  title: Text(
                    action.label,
                    style: TextStyle(color: action.color ?? AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(action.value),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

Future<bool> showNotesConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  Color confirmColor = AppColors.error,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

Future<T?> showNotesSelectionDialog<T>(
  BuildContext context, {
  required String title,
  required String emptyMessage,
  required List<NotesSelectionDialogItem<T>> items,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: 420,
        child: items.isEmpty
            ? Text(
                emptyMessage,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.divider, height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(
                        item.label,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: item.subtitle == null
                          ? null
                          : Text(
                              item.subtitle!,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                      onTap: () => Navigator.of(dialogContext).pop(item.value),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
