import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/instant_notes/application/instant_notes_store.dart';
import 'package:memory_notes/features/notes/application/category_controller.dart';
import 'package:memory_notes/features/notes/application/todo_file_controller.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';
import 'package:signals/signals_flutter.dart';

class InstantNotesScreen extends StatefulWidget {
  const InstantNotesScreen({
    required this.instantNotes,
    required this.todoFiles,
    required this.categories,
    required this.speech,
    super.key,
  });

  final InstantNotesStore instantNotes;
  final TodoFileController todoFiles;
  final CategoryController categories;
  final SpeechController speech;

  @override
  State<InstantNotesScreen> createState() => _InstantNotesScreenState();
}

class _InstantNotesScreenState extends State<InstantNotesScreen>
    with SingleTickerProviderStateMixin {
  final _speechOwner = Object();
  final _noteController = TextEditingController();
  final _showList = signal(false);
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  StreamSubscription<String>? _recognitionSub;
  StreamSubscription<void>? _completionSub;
  StreamSubscription<SpeechStatus>? _statusSub;
  bool _isListening = false;
  bool _didInitialize = false;
  int? _lastMoveFileId;
  int? _lastMoveCategoryId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _statusSub = widget.speech.statusStream.listen((_) {
      final isOwnedSession = identical(widget.speech.activeOwner.value, _speechOwner);
      final nextListening = widget.speech.isListening && isOwnedSession;
      if (!isOwnedSession && _isListening) {
        _finishListening();
        return;
      }
      if (!mounted || _isListening == nextListening) return;
      setState(() => _isListening = nextListening);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.instantNotes.load();
      widget.todoFiles.load();
    });
  }

  @override
  void dispose() {
    if (_isListening && identical(widget.speech.activeOwner.value, _speechOwner)) {
      widget.speech.stopListening();
    }
    _recognitionSub?.cancel();
    _completionSub?.cancel();
    _statusSub?.cancel();
    _noteController.dispose();
    _pulseController.dispose();
    _showList.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening || widget.speech.isListening) {
      await widget.speech.stopListening();
      _finishListening();
      return;
    }

    _attachSpeechSubscriptions();
    final started = await widget.speech.startListening(owner: _speechOwner);
    if (!started) {
      _finishListening();
      _showMessage(widget.speech.errorMessage.value ?? 'Speech recognition is unavailable.');
      return;
    }
    setState(() => _isListening = true);
  }

  void _attachSpeechSubscriptions() {
    _recognitionSub?.cancel();
    _recognitionSub = widget.speech.recognizedTextStream.listen((text) {
      if (!identical(widget.speech.activeOwner.value, _speechOwner)) return;
      _applyRecognizedText(text);
    });

    _completionSub?.cancel();
    _completionSub = widget.speech.completionStream.listen((_) {
      final finalText = widget.speech.lastRecognizedText.value.trim();
      if (finalText.isNotEmpty) {
        _applyRecognizedText(finalText);
      }
      _finishListening();
    });
  }

  void _applyRecognizedText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final nextText = _capitalizeFirstWord(trimmed);
    _noteController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  String _capitalizeFirstWord(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  void _finishListening() {
    _recognitionSub?.cancel();
    _completionSub?.cancel();
    _recognitionSub = null;
    _completionSub = null;
    if (mounted) {
      setState(() => _isListening = false);
    } else {
      _isListening = false;
    }
  }

  Future<void> _saveInstantNote() async {
    final noteText = _noteController.text;
    if (identical(widget.speech.activeOwner.value, _speechOwner)) {
      _finishListening();
      await widget.speech.stopListening();
    }
    final created = await widget.instantNotes.create(noteText);
    if (!mounted) return;
    if (created == null) {
      _showMessage('Add a note before saving.');
      return;
    }
    _noteController.clear();
    _showMessage('Instant note saved.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final showList = _showList.value;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            titleSpacing: 16,
            title: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEMORY NOTES',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      showList ? 'Instant Notes' : 'Instant',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            toolbarHeight: 112,
            actions: [
              IconButton(
                tooltip: showList ? 'Capture note' : 'View instant notes',
                icon: Icon(
                  showList ? Icons.mic_none_rounded : Icons.list_alt_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => _showList.value = !showList,
              ),
            ],
          ),
          body: showList ? _buildInstantNotesList(context) : _buildCaptureView(context),
        );
      },
    );
  }

  Widget _buildCaptureView(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final isSaving = widget.instantNotes.isSaving.value;
        return SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttonSize = (constraints.maxHeight * 0.30).clamp(144.0, 220.0);
              final iconSize = (buttonSize * 0.38).clamp(54.0, 82.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight < 620 ? 8 : 28),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Transform.scale(
                        scale: _isListening ? _scaleAnimation.value : 1,
                        child: child,
                      ),
                      child: SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: _isListening ? AppColors.error : AppColors.accent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: isSaving ? null : _toggleListening,
                          child: Icon(
                            _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isListening ? 'Listening' : 'Tap to speak',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _noteController,
                      minLines: constraints.maxHeight < 620 ? 3 : 4,
                      maxLines: constraints.maxHeight < 620 ? 5 : 7,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Your instant note will appear here...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(isSaving ? 'Saving' : 'Save Instant Note'),
                        onPressed: isSaving ? null : _saveInstantNote,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInstantNotesList(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final notes = widget.instantNotes.instantNotes.value;
        final isLoading = widget.instantNotes.isLoading.value;
        if (isLoading && notes.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }
        if (notes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speaker_notes_off_rounded, size: 48, color: AppColors.textDisabled),
                SizedBox(height: 16),
                Text(
                  'No instant notes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: widget.instantNotes.load,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _InstantNoteCard(
                key: ValueKey(note.id ?? note.createdAt),
                note: note,
                onMove: () => _showMoveSheet(note),
                onDelete: () => widget.instantNotes.delete(note),
                onSave: (notes) => widget.instantNotes.update(note, notes),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showMoveSheet(InstantNote note) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _MoveInstantNoteSheet(
          note: note,
          instantNotes: widget.instantNotes,
          todoFiles: widget.todoFiles,
          categories: widget.categories,
          speech: widget.speech,
          initialFileId: _lastMoveFileId,
          initialCategoryId: _lastMoveCategoryId,
          onDestinationUsed: (fileId, categoryId) {
            _lastMoveFileId = fileId;
            _lastMoveCategoryId = categoryId;
          },
        );
      },
    );
  }
}

class _InstantNoteCard extends StatefulWidget {
  const _InstantNoteCard({
    required this.note,
    required this.onMove,
    required this.onDelete,
    required this.onSave,
    super.key,
  });

  final InstantNote note;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final Future<InstantNote?> Function(String notes) onSave;

  @override
  State<_InstantNoteCard> createState() => _InstantNoteCardState();
}

class _InstantNoteCardState extends State<_InstantNoteCard> {
  late final TextEditingController _notesController;
  late String _savedNotes;
  bool _isSaving = false;

  bool get _canSave =>
      !_isSaving &&
      _notesController.text.trim().isNotEmpty &&
      _notesController.text.trim() != _savedNotes;

  @override
  void initState() {
    super.initState();
    _savedNotes = widget.note.notes;
    _notesController = TextEditingController(text: _savedNotes)..addListener(_handleNotesChanged);
  }

  @override
  void didUpdateWidget(covariant _InstantNoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _savedNotes = widget.note.notes;
      _notesController.text = _savedNotes;
      return;
    }
    if (oldWidget.note.notes != widget.note.notes) {
      _savedNotes = widget.note.notes;
    }
  }

  @override
  void dispose() {
    _notesController
      ..removeListener(_handleNotesChanged)
      ..dispose();
    super.dispose();
  }

  void _handleNotesChanged() {
    setState(() {});
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _isSaving = true);
    final updated = await widget.onSave(_notesController.text);
    if (!mounted) return;
    if (updated != null) {
      _savedNotes = updated.notes;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save instant note.')),
      );
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.note.createdAt;
    final timestamp = createdAt == null
        ? 'No timestamp'
        : DateFormat('MMM d, yyyy h:mm a').format(createdAt.toLocal());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timestamp,
                style: const TextStyle(
                  color: AppColors.accentLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 5,
                minLines: 1,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.35),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Instant note',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(_isSaving ? 'Saving' : 'Save'),
                    onPressed: _canSave ? _save : null,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.textSecondary,
                    onPressed: widget.onDelete,
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.drive_file_move_rounded, size: 18),
                    label: const Text('Move'),
                    onPressed: widget.onMove,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoveInstantNoteSheet extends StatefulWidget {
  const _MoveInstantNoteSheet({
    required this.note,
    required this.instantNotes,
    required this.todoFiles,
    required this.categories,
    required this.speech,
    required this.initialFileId,
    required this.initialCategoryId,
    required this.onDestinationUsed,
  });

  final InstantNote note;
  final InstantNotesStore instantNotes;
  final TodoFileController todoFiles;
  final CategoryController categories;
  final SpeechController speech;
  final int? initialFileId;
  final int? initialCategoryId;
  final void Function(int fileId, int categoryId) onDestinationUsed;

  @override
  State<_MoveInstantNoteSheet> createState() => _MoveInstantNoteSheetState();
}

class _MoveInstantNoteSheetState extends State<_MoveInstantNoteSheet> {
  final _todoNameController = TextEditingController();
  int? _selectedFileId;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _todoNameController.addListener(_handleTodoNameChanged);
    final files = _sortedFiles();
    if (files.isNotEmpty) {
      final rememberedFile = files.where((file) => file.id == widget.initialFileId).firstOrNull;
      _selectedFileId = rememberedFile?.id ?? files.first.id;
      widget.categories.loadCategories(_selectedFileId!);
      _selectedCategoryId = widget.initialCategoryId;
    }
  }

  @override
  void dispose() {
    _todoNameController.removeListener(_handleTodoNameChanged);
    _todoNameController.dispose();
    super.dispose();
  }

  void _handleTodoNameChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<TodoFile> _sortedFiles() {
    final files = widget.todoFiles.todoFiles.value.where((file) => file.id != null).toList();
    files.sort((a, b) => _fileModifiedAt(b).compareTo(_fileModifiedAt(a)));
    return files;
  }

  DateTime _fileModifiedAt(TodoFile file) {
    return file.lastUpdated ?? file.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _selectFile(int? fileId) async {
    if (fileId == null) return;
    setState(() {
      _selectedFileId = fileId;
      _selectedCategoryId = null;
    });
    await widget.categories.loadCategories(fileId);
    if (!mounted) return;
    final categories = _categoriesForSelectedFile();
    if (categories.isNotEmpty) {
      setState(() => _selectedCategoryId = categories.first.id);
    }
  }

  List<Category> _categoriesForSelectedFile() {
    final fileId = _selectedFileId;
    if (fileId == null) return const <Category>[];
    return widget.categories.categories.value
        .where((category) => category.todoFileId == fileId && category.id != null)
        .toList(growable: false);
  }

  Future<void> _move() async {
    final fileId = _selectedFileId;
    final categoryId = _selectedCategoryId;
    if (fileId == null || categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choose a list and category first.')));
      return;
    }
    final moved = await widget.instantNotes.moveToTodo(
      instantNote: widget.note,
      fileId: fileId,
      categoryId: categoryId,
      todoName: _todoNameController.text,
    );
    if (!mounted) return;
    if (moved) {
      widget.onDestinationUsed(fileId, categoryId);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moved to todo.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.instantNotes.error.value ?? 'Could not move note.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final files = _sortedFiles();
        final categories = _categoriesForSelectedFile();
        final hasSelectedCategory = categories.any(
          (category) => category.id == _selectedCategoryId,
        );
        if (!hasSelectedCategory && categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
        final isSaving = widget.instantNotes.isSaving.value;
        final canCreateTodo = _todoNameController.text.trim().isNotEmpty && !isSaving;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Move to Todo',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _todoNameController,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Todo title',
                      helperText: 'This becomes the new todo name.',
                      suffixIcon: SpeechMicButton(
                        controller: _todoNameController,
                        speech: widget.speech,
                        appendToExistingText: false,
                        onError: (message) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: ValueKey('instant-note-file-$_selectedFileId'),
                    initialValue: _selectedFileId,
                    decoration: const InputDecoration(labelText: 'List'),
                    dropdownColor: AppColors.surface,
                    items: [
                      for (final file in files)
                        DropdownMenuItem(value: file.id, child: Text(file.name)),
                    ],
                    onChanged: isSaving ? null : _selectFile,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: ValueKey('instant-note-category-$_selectedFileId-$_selectedCategoryId'),
                    initialValue: categories.any((category) => category.id == _selectedCategoryId)
                        ? _selectedCategoryId
                        : null,
                    decoration: const InputDecoration(labelText: 'Category'),
                    dropdownColor: AppColors.surface,
                    items: [
                      for (final category in categories)
                        DropdownMenuItem(value: category.id, child: Text(category.name)),
                    ],
                    onChanged: isSaving
                        ? null
                        : (value) => setState(() => _selectedCategoryId = value),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Instant note text',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      widget.note.notes,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      TextButton(
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(isSaving ? 'Moving' : 'Create Todo'),
                          onPressed: canCreateTodo ? _move : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
