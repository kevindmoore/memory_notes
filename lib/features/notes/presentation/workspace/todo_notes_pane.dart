import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';

const desktopTodoNotesPaneMinWidth = 360.0;

class DesktopTodoNotesPane extends StatefulWidget {
  const DesktopTodoNotesPane({
    super.key,
    required this.todo,
    required this.focusRequestId,
    required this.onSave,
    required this.speech,
  });

  final Todo? todo;
  final int focusRequestId;
  final Future<void> Function(Todo todo, String notes) onSave;
  final SpeechController speech;

  @override
  State<DesktopTodoNotesPane> createState() => _DesktopTodoNotesPaneState();
}

class _DesktopTodoNotesPaneState extends State<DesktopTodoNotesPane> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _saveTimer;
  String _lastSavedNotes = '';
  bool _isSaving = false;
  bool _showPreview = false;
  bool _restoreFocusOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncFromTodo();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DesktopTodoNotesPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldFocusNotes =
        oldWidget.focusRequestId != widget.focusRequestId && widget.todo != null;
    if (oldWidget.todo?.id != widget.todo?.id) {
      _saveTimer?.cancel();
      _syncFromTodo();
      if (shouldFocusNotes) {
        _requestNotesFocus();
      }
      return;
    }

    if (shouldFocusNotes) {
      _requestNotesFocus();
    }

    final nextTodo = widget.todo;
    if (nextTodo == null) return;

    final storeNotesChanged = oldWidget.todo?.notes != nextTodo.notes;
    final userHasPendingEdits = _controller.text != _lastSavedNotes;
    if (storeNotesChanged && !_focusNode.hasFocus && !userHasPendingEdits) {
      _setControllerText(nextTodo.notes);
      _lastSavedNotes = nextTodo.notes;
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_restoreFocusOnResume && !_showPreview) {
        _requestNotesFocus();
      }
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _restoreFocusOnResume = _restoreFocusOnResume || _focusNode.hasFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    return Container(
      constraints: const BoxConstraints(minWidth: desktopTodoNotesPaneMinWidth),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.divider)),
      ),
      child: todo == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Select a task to view and edit its notes.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Task Notes',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSaving)
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Text(
                              'Saving...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        SpeechMicButton(
                          controller: _controller,
                          speech: widget.speech,
                        ),
                        IconButton(
                          onPressed: _togglePreview,
                          icon: Icon(
                            _showPreview ? Icons.edit_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: _showPreview ? 'Edit markdown' : 'Preview markdown',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _showPreview
                        ? _buildMarkdownPreview(context)
                        : TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Write notes for this task...',
                              alignLabelWithHint: true,
                            ),
                            onChanged: (_) => _scheduleAutosave(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _restoreFocusOnResume = true;
      return;
    }

    if (!_focusNode.hasFocus) {
      unawaited(_flushSave());
    }
  }

  void _scheduleAutosave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_flushSave());
    });
  }

  Future<void> _flushSave() async {
    _saveTimer?.cancel();
    final todo = widget.todo;
    final notes = _controller.text;
    if (todo == null || _isSaving || notes == _lastSavedNotes) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSave(todo, notes);
      _lastSavedNotes = notes;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (_controller.text != _lastSavedNotes) {
      if (_focusNode.hasFocus) {
        _scheduleAutosave();
      } else {
        unawaited(_flushSave());
      }
    }
  }

  void _syncFromTodo() {
    final notes = widget.todo?.notes ?? '';
    _setControllerText(notes);
    _lastSavedNotes = notes;
  }

  void _setControllerText(String notes) {
    _controller.value = TextEditingValue(
      text: notes,
      selection: TextSelection.collapsed(offset: notes.length),
    );
  }

  void _requestNotesFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.todo == null) return;
      _focusNode.requestFocus();
    });
  }

  void _togglePreview() {
    if (!_showPreview) {
      _restoreFocusOnResume = false;
      _focusNode.unfocus();
      unawaited(_flushSave());
    }
    setState(() => _showPreview = !_showPreview);
  }

  Widget _buildMarkdownPreview(BuildContext context) {
    final notes = _controller.text;
    if (notes.trim().isEmpty) {
      return const Center(
        child: Text(
          'No notes yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Markdown(
        data: notes,
        selectable: true,
        padding: const EdgeInsets.all(16),
        styleSheet: _markdownStyleSheet(context),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyleSheet(BuildContext context) {
    const baseTextStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15,
      height: 1.5,
    );
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: baseTextStyle,
      h1: baseTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
      h2: baseTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      h3: baseTextStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
      strong: baseTextStyle.copyWith(fontWeight: FontWeight.w700),
      em: baseTextStyle.copyWith(fontStyle: FontStyle.italic),
      listBullet: baseTextStyle,
      blockquote: baseTextStyle.copyWith(color: AppColors.textSecondary),
      code: baseTextStyle.copyWith(
        backgroundColor: AppColors.background,
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
      ),
    );
  }
}
