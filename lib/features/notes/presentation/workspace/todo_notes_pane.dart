import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';

const desktopTodoNotesPaneMinWidth = 360.0;

class DesktopTodoNotesPane extends StatefulWidget {
  const DesktopTodoNotesPane({
    super.key,
    required this.todo,
    required this.onSave,
    required this.speech,
  });

  final Todo? todo;
  final Future<void> Function(Todo todo, String notes) onSave;
  final SpeechController speech;

  @override
  State<DesktopTodoNotesPane> createState() => _DesktopTodoNotesPaneState();
}

class _DesktopTodoNotesPaneState extends State<DesktopTodoNotesPane> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _saveTimer;
  String _lastSavedNotes = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _syncFromTodo();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DesktopTodoNotesPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todo?.id != widget.todo?.id) {
      _saveTimer?.cancel();
      _syncFromTodo();
      return;
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
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
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
}
