import 'package:memory_notes/core/presentation/connection_banner.dart';
import 'package:memory_notes/core/services/connection_service.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/data/models.dart';
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

class CopyNoteDestination {
  const CopyNoteDestination({
    required this.fileId,
    required this.categoryId,
    required this.parentTodoId,
  });

  final int fileId;
  final int categoryId;
  final int? parentTodoId;
}

Future<String?> showNotesTextPromptDialog(
  BuildContext context, {
  required String title,
  required String hintText,
  required String confirmLabel,
  String? initialValue,
  bool multiline = false,
  SpeechController? speech,
  String? Function(String value)? validator,
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
      validator: validator,
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
    required this.validator,
  });

  final String title;
  final String hintText;
  final String confirmLabel;
  final String? initialValue;
  final bool multiline;
  final SpeechController? speech;
  final String? Function(String value)? validator;

  @override
  State<_NotesTextPromptDialog> createState() => _NotesTextPromptDialogState();
}

class _NotesTextPromptDialogState extends State<_NotesTextPromptDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _errorText = _validate(_controller.text);
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final nextError = _validate(_controller.text);
    if (nextError == _errorText) return;
    setState(() {
      _errorText = nextError;
    });
  }

  String? _validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return widget.validator?.call(trimmed);
  }

  void _close([String? value]) {
    final trimmed = value?.trim() ?? '';
    final error = _validate(trimmed);
    if (trimmed.isNotEmpty && error != null) {
      setState(() {
        _errorText = error;
      });
      return;
    }
    final speech = widget.speech;
    if (speech != null && speech.activeOwner.value != null) {
      unawaited(speech.stopListening());
    }
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
          errorText: _errorText,
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
          onPressed: _errorText == null ? () => _close(_controller.text.trim()) : null,
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
  required String searchHintText,
  required List<NotesSelectionDialogItem<T>> items,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      var query = '';
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final normalizedQuery = query.trim().toLowerCase();
          final filteredItems = normalizedQuery.isEmpty
              ? items
              : items
                  .where((item) => item.label.toLowerCase().contains(normalizedQuery))
                  .toList(growable: false);
          final mediaQuery = MediaQuery.of(context);
          final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
          final contentMaxHeight = (mediaQuery.size.height -
                  mediaQuery.viewInsets.bottom -
                  (isKeyboardVisible ? 68 : 220))
              .clamp(120.0, 420.0)
              .toDouble();
          return AlertDialog(
            backgroundColor: AppColors.surface,
            contentPadding: isKeyboardVisible
                ? const EdgeInsets.fromLTRB(24, 8, 24, 8)
                : null,
            actionsPadding: isKeyboardVisible
                ? const EdgeInsets.fromLTRB(8, 0, 16, 4)
                : null,
            title: isKeyboardVisible
                ? null
                : Text(
                    title,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
            content: SizedBox(
              width: 420,
              height: contentMaxHeight,
              child: items.isEmpty
                  ? SingleChildScrollView(
                      child: Text(
                        emptyMessage,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: searchHintText,
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textDisabled,
                            ),
                          ),
                          onChanged: (value) => setDialogState(() => query = value),
                        ),
                        SizedBox(height: isKeyboardVisible ? 4 : 12),
                        Expanded(
                          child: filteredItems.isEmpty
                              ? SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Text(
                                      'No lists found for "${query.trim()}"',
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: filteredItems.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(color: AppColors.divider, height: 1),
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
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
                      ],
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<CopyNoteDestination?> showCopyNoteDestinationDialog(
  BuildContext context, {
  required Todo sourceTodo,
  required List<TodoFile> files,
  required Future<List<Category>> Function(int fileId) loadCategories,
  required Future<List<Todo>> Function(int categoryId) loadTodos,
}) {
  return showDialog<CopyNoteDestination>(
    context: context,
    builder: (dialogContext) => _CopyNoteDestinationDialog(
      sourceTodo: sourceTodo,
      files: files,
      loadCategories: loadCategories,
      loadTodos: loadTodos,
    ),
  );
}

class _CopyNoteDestinationDialog extends StatefulWidget {
  const _CopyNoteDestinationDialog({
    required this.sourceTodo,
    required this.files,
    required this.loadCategories,
    required this.loadTodos,
  });

  final Todo sourceTodo;
  final List<TodoFile> files;
  final Future<List<Category>> Function(int fileId) loadCategories;
  final Future<List<Todo>> Function(int categoryId) loadTodos;

  @override
  State<_CopyNoteDestinationDialog> createState() => _CopyNoteDestinationDialogState();
}

class _CopyNoteDestinationDialogState extends State<_CopyNoteDestinationDialog> {
  TodoFile? _selectedFile;
  Category? _selectedCategory;
  List<Category> _categories = const [];
  List<Todo> _todos = const [];
  bool _isLoading = false;
  String? _loadError;
  String _query = '';

  Future<void> _selectFile(TodoFile file) async {
    final fileId = file.id;
    if (fileId == null) return;
    setState(() {
      _selectedFile = file;
      _selectedCategory = null;
      _categories = const [];
      _todos = const [];
      _isLoading = true;
      _loadError = null;
      _query = '';
    });
    try {
      final categories = await widget.loadCategories(fileId).timeout(ConnectionService.requestTimeout);
      if (!mounted || _selectedFile?.id != fileId) return;
      setState(() => _categories = List<Category>.from(categories)..sort(_compareCategoriesByLastUsed));
    } catch (error) {
      if (mounted && _selectedFile?.id == fileId) setState(() => _loadError = error.toString());
    } finally {
      if (mounted && _selectedFile?.id == fileId) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectCategory(Category category) async {
    final categoryId = category.id;
    if (categoryId == null) return;
    setState(() {
      _selectedCategory = category;
      _todos = const [];
      _isLoading = true;
      _loadError = null;
      _query = '';
    });
    try {
      final todos = await widget.loadTodos(categoryId).timeout(ConnectionService.requestTimeout);
      if (!mounted || _selectedCategory?.id != categoryId) return;
      setState(() {
        _todos = todos.where((todo) => todo.id != widget.sourceTodo.id).toList(growable: false)
          ..sort(_compareTodosByLastUsed);
      });
    } catch (error) {
      if (mounted && _selectedCategory?.id == categoryId) setState(() => _loadError = error.toString());
    } finally {
      if (mounted && _selectedCategory?.id == categoryId) setState(() => _isLoading = false);
    }
  }

  void _copyToCategory() {
    final fileId = _selectedFile?.id;
    final categoryId = _selectedCategory?.id;
    if (fileId == null || categoryId == null) return;
    Navigator.of(context).pop(
      CopyNoteDestination(
        fileId: fileId,
        categoryId: categoryId,
        parentTodoId: null,
      ),
    );
  }

  void _goBack() {
    setState(() {
      if (_selectedCategory != null) {
        _selectedCategory = null;
        _todos = const [];
      } else {
        _selectedFile = null;
        _categories = const [];
      }
      _isLoading = false;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isChoosingFile = _selectedFile == null;
    final isChoosingCategory = _selectedFile != null && _selectedCategory == null;
    final normalizedQuery = _query.trim().toLowerCase();
    final sortedFiles = List<TodoFile>.from(widget.files)..sort(_compareFilesByLastUsed);
    final items = isChoosingFile
        ? sortedFiles
        : isChoosingCategory
        ? _categories
        : _todos;
    final filteredItems = normalizedQuery.isEmpty
        ? items
        : items.where((item) {
            final name = switch (item) {
              TodoFile() => item.name,
              Category() => item.name,
              Todo() => item.name,
              _ => '',
            };
            return name.toLowerCase().contains(normalizedQuery);
          }).toList(growable: false);
    final searchHint = isChoosingFile
        ? 'Search lists...'
        : isChoosingCategory
        ? 'Search categories...'
        : 'Search notes...';

    return AlertDialog(
      backgroundColor: AppColors.surface,
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      title: Row(
        children: [
          if (!isChoosingFile)
            IconButton(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
          const Expanded(
            child: Text(
              'Copy Note',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedCategory != null
                  ? '${_selectedFile!.name} / ${_selectedCategory!.name} / Choose a note (optional)'
                  : _selectedFile != null
                  ? '${_selectedFile!.name} / Choose a category'
                  : 'Choose a list',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (_selectedCategory != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _copyToCategory,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy to this category'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              key: ValueKey(searchHint),
              autofocus: true,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textDisabled,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : _loadError != null
                  ? LoadErrorView(error: _loadError!, onRetry: () async {
                      if (_selectedCategory != null) {
                        await _selectCategory(_selectedCategory!);
                      } else if (_selectedFile != null) {
                        await _selectFile(_selectedFile!);
                      }
                    })
                  : filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        normalizedQuery.isNotEmpty
                            ? 'No ${isChoosingFile
                                  ? 'lists'
                                  : isChoosingCategory
                                  ? 'categories'
                                  : 'notes'} found for "${_query.trim()}".'
                            : isChoosingFile
                            ? 'No lists available.'
                            : isChoosingCategory
                            ? 'This list has no categories.'
                            : 'This category has no other notes.',
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: AppColors.divider, height: 1),
                      itemBuilder: (context, index) {
                        if (isChoosingFile) {
                          final file = filteredItems[index] as TodoFile;
                          return ListTile(
                            title: Text(file.name),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _selectFile(file),
                          );
                        }
                        if (isChoosingCategory) {
                          final category = filteredItems[index] as Category;
                          return ListTile(
                            title: Text(category.name),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _selectCategory(category),
                          );
                        }
                        final todo = filteredItems[index] as Todo;
                        return ListTile(
                          title: Text(todo.name),
                          subtitle: todo.parentTodoId == null
                              ? null
                              : const Text('Child note'),
                          leading: const Icon(Icons.note_outlined),
                          onTap: () {
                            final fileId = _selectedFile!.id;
                            final categoryId = _selectedCategory!.id;
                            final parentTodoId = todo.id;
                            if (fileId == null || categoryId == null || parentTodoId == null) {
                              return;
                            }
                            Navigator.of(context).pop(
                              CopyNoteDestination(
                                fileId: fileId,
                                categoryId: categoryId,
                                parentTodoId: parentTodoId,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  static int _compareFilesByLastUsed(TodoFile left, TodoFile right) {
    final byLastUsed = _lastUsed(right.lastUpdated, right.createdAt).compareTo(
      _lastUsed(left.lastUpdated, left.createdAt),
    );
    return byLastUsed != 0 ? byLastUsed : left.name.toLowerCase().compareTo(right.name.toLowerCase());
  }

  static int _compareCategoriesByLastUsed(Category left, Category right) {
    final byLastUsed = _lastUsed(right.lastUpdated, right.createdAt).compareTo(
      _lastUsed(left.lastUpdated, left.createdAt),
    );
    return byLastUsed != 0 ? byLastUsed : left.name.toLowerCase().compareTo(right.name.toLowerCase());
  }

  static int _compareTodosByLastUsed(Todo left, Todo right) {
    final byLastUsed = _lastUsed(right.lastUpdated, right.createdAt).compareTo(
      _lastUsed(left.lastUpdated, left.createdAt),
    );
    return byLastUsed != 0 ? byLastUsed : left.name.toLowerCase().compareTo(right.name.toLowerCase());
  }

  static DateTime _lastUsed(DateTime? lastUpdated, DateTime? createdAt) {
    return lastUpdated ?? createdAt ?? DateTime(0);
  }
}

@Preview(name: 'Open list search dialog', group: 'Notes')
Widget notesSelectionDialogPreview() {
  return MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () async {
              await showNotesSelectionDialog<int>(
                context,
                title: 'Open List',
                emptyMessage: 'All lists are already open.',
                searchHintText: 'Search lists...',
                items: const [
                  NotesSelectionDialogItem(value: 1, label: 'Personal', subtitle: '4 categories'),
                  NotesSelectionDialogItem(value: 2, label: 'Work', subtitle: '7 categories'),
                  NotesSelectionDialogItem(value: 3, label: 'Travel', subtitle: '2 categories'),
                ],
              );
            },
            child: const Text('Open List'),
          ),
        ),
      ),
    ),
  );
}
