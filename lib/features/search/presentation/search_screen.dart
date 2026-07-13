import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
import 'package:memory_notes/features/notes/application/notes_workspace_store.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/presentation/actions/notes_actions.dart';
import 'package:memory_notes/features/search/application/search_store.dart';
import 'package:memory_notes/features/search/models/search_result_item.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';
import 'package:memory_notes/features/speech/presentation/speech_mic_button.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage(name: 'SearchRoute')
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.search,
    required this.notesMobile,
    required this.notesWorkspace,
    required this.noteDetailActions,
    required this.noteEditActions,
    required this.speech,
    super.key,
  });
  final SearchStore search;
  final NotesMobileStore notesMobile;
  final NotesWorkspaceStore notesWorkspace;
  final NoteDetailActions noteDetailActions;
  final NoteEditActions noteEditActions;
  final SpeechController speech;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _query = signal('');
  bool _didPreload = false;
  bool _isPreparingSearch = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => _query.value = _searchCtrl.text.trim().toLowerCase());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPreload) return;
    _didPreload = true;
    _preload();
  }

  Future<void> _preload() async {
    try {
      await widget.notesWorkspace.initialize();
      if (!mounted) return;
      await widget.search.preload(
        openFileIds: widget.notesWorkspace.workspace.openFileIds.value,
      );
    } finally {
      if (mounted) {
        setState(() => _isPreparingSearch = false);
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              autocorrect: false,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search lists, categories, tasks...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.search_rounded, color: AppColors.textDisabled, size: 20),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                suffixIcon: SignalBuilder(
                  builder: (context) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpeechMicButton(
                        controller: _searchCtrl,
                        speech: widget.speech,
                        appendToExistingText: false,
                        onError: (message) => ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message))),
                      ),
                      if (_query.value.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textDisabled,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            _query.value = '';
                          },
                        ),
                    ],
                  ),
                ),
                fillColor: AppColors.surfaceVariant,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final q = _query.value;

                if (q.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_rounded, size: 56, color: AppColors.textDisabled),
                        SizedBox(height: 16),
                        Text(
                          'Search your notes',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Type to find lists, categories and tasks',
                          style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                if (_isPreparingSearch || widget.search.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                }

                final openFileIds = widget.notesWorkspace.query.normalizeFileIds(
                  widget.notesWorkspace.workspace.openFileIds.value,
                  widget.search.todoFiles.todoFiles.value,
                );
                final results = widget.search.buildResults(q, openFileIds: openFileIds);

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results for "$q"',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try a different search term',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  itemCount: results.length,
                  itemBuilder: (context, resultIndex) =>
                      _buildResultTile(context, results[resultIndex], q),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResultItem result, String query) {
    return switch (result) {
      SearchFileResultItem(file: final file) => ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentDim,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder_rounded, color: AppColors.accent, size: 20),
        ),
        title: _HighlightedText(text: file.name, query: query),
        subtitle: const Text('List', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
        onTap: () => _openFileResult(context, file),
      ),
      SearchCategoryResultItem(
        category: final category,
        parentFile: final file,
        subtitle: final subtitle,
      ) =>
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentDim.withAlpha(160),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_open_rounded, color: AppColors.accent, size: 20),
          ),
          title: _HighlightedText(text: category.name, query: query),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
          ),
          onTap: () => _openCategoryResult(context, file: file, category: category),
        ),
      SearchTodoResultItem(
        todo: final todo,
        ancestorTodoIds: final ancestorTodoIds,
        parentCategory: final category,
        parentFile: final file,
        subtitle: final subtitle,
      ) =>
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(
              todo.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: todo.done ? AppColors.accent : AppColors.textDisabled,
              size: 20,
            ),
          ),
          title: _HighlightedText(text: todo.name, query: query),
          subtitle: _buildTodoSubtitle(subtitle, query),
          onTap: () => _openTodoResult(
            context,
            file: file,
            category: category,
            todo: todo,
            ancestorTodoIds: ancestorTodoIds,
          ),
        ),
    };
  }

  Future<void> _openFileResult(BuildContext context, TodoFile file) async {
    final fileId = file.id;
    if (fileId == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_usesWorkspaceSelection(context)) {
      await widget.notesWorkspace.openFile(file);
      if (!context.mounted) return;
      AutoTabsRouter.of(context).navigate(const NotesTabRoute());
      return;
    }
    context.router.push(_buildNoteDetailRoute(fileId));
  }

  Future<void> _openCategoryResult(
    BuildContext context, {
    required TodoFile file,
    required Category category,
  }) async {
    final fileId = file.id;
    final categoryId = category.id;
    if (fileId == null || categoryId == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_usesWorkspaceSelection(context)) {
      await widget.notesWorkspace.openFile(file);
      await widget.notesWorkspace.selectCategory(file: file, category: category);
      if (!context.mounted) return;
      AutoTabsRouter.of(context).navigate(const NotesTabRoute());
      return;
    }
    context.router.pushAll([
      _buildNoteDetailRoute(fileId),
      _buildNoteEditRoute(fileId: fileId, categoryId: categoryId),
    ]);
  }

  Future<void> _openTodoResult(
    BuildContext context, {
    required TodoFile file,
    required Category category,
    required Todo todo,
    required List<int> ancestorTodoIds,
  }) async {
    final fileId = file.id;
    final categoryId = category.id;
    final todoId = todo.id;
    if (fileId == null || categoryId == null || todoId == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final todoPath = <int>[...ancestorTodoIds, todoId];
    if (_usesWorkspaceSelection(context)) {
      await widget.notesWorkspace.openFile(file);
      widget.notesWorkspace.selectTodo(fileId: fileId, categoryId: categoryId, todoPath: todoPath);
      if (!context.mounted) return;
      AutoTabsRouter.of(context).navigate(const NotesTabRoute());
      return;
    }
    final routes = <PageRouteInfo>[
      _buildNoteDetailRoute(fileId),
      _buildNoteEditRoute(fileId: fileId, categoryId: categoryId),
    ];
    for (final ancestorTodoId in ancestorTodoIds) {
      routes.add(
        _buildNoteEditRoute(
          fileId: fileId,
          categoryId: categoryId,
          parentTodoId: ancestorTodoId,
          focusedTodoId: ancestorTodoId,
        ),
      );
    }
    routes.add(
      _buildNoteEditRoute(
        fileId: fileId,
        categoryId: categoryId,
        parentTodoId: todo.parentTodoId,
        focusedTodoId: todoId,
        openFocusedTodoNotes: true,
      ),
    );
    context.router.pushAll(routes);
  }

  NoteDetailRoute _buildNoteDetailRoute(int fileId) {
    return NoteDetailRoute(
      fileId: fileId,
      notesMobile: widget.notesMobile,
      noteDetailActions: widget.noteDetailActions,
      noteEditActions: widget.noteEditActions,
      speech: widget.speech,
    );
  }

  NoteEditRoute _buildNoteEditRoute({
    required int fileId,
    required int categoryId,
    int? parentTodoId,
    int? focusedTodoId,
    bool openFocusedTodoNotes = false,
  }) {
    return NoteEditRoute(
      fileId: fileId,
      categoryId: categoryId,
      parentTodoId: parentTodoId,
      focusedTodoId: focusedTodoId,
      openFocusedTodoNotes: openFocusedTodoNotes,
      notesMobile: widget.notesMobile,
      noteEditActions: widget.noteEditActions,
      speech: widget.speech,
    );
  }

  bool _usesWorkspaceSelection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (kIsWeb) {
      return width >= 700;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return width >= 700;
    }
  }

  Widget _buildTodoSubtitle(String subtitle, String query) {
    final newline = subtitle.indexOf('\n');
    if (newline == -1) {
      return Text(subtitle, style: const TextStyle(color: AppColors.textDisabled, fontSize: 12));
    }
    final breadcrumb = subtitle.substring(0, newline);
    final snippet = subtitle.substring(newline + 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(breadcrumb, style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
        const SizedBox(height: 2),
        _HighlightedText(
          text: snippet,
          query: query,
          baseStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Highlights every occurrence of every query word in accent color.
// ---------------------------------------------------------------------------

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;

  const _HighlightedText({
    required this.text,
    required this.query,
    this.baseStyle = const TextStyle(color: AppColors.textPrimary),
  });

  @override
  Widget build(BuildContext context) {
    final words = query.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (words.isEmpty) return Text(text, style: baseStyle);

    final lower = text.toLowerCase();

    // Collect all match ranges for every word.
    final ranges = <(int, int)>[];
    for (final word in words) {
      var start = 0;
      while (start < lower.length) {
        final idx = lower.indexOf(word, start);
        if (idx == -1) break;
        ranges.add((idx, idx + word.length));
        start = idx + word.length;
      }
    }

    if (ranges.isEmpty) return Text(text, style: baseStyle);

    // Sort then merge overlapping/adjacent ranges.
    ranges.sort((a, b) => a.$1.compareTo(b.$1));
    final merged = <(int, int)>[];
    for (final r in ranges) {
      if (merged.isEmpty || r.$1 >= merged.last.$2) {
        merged.add(r);
      } else {
        final last = merged.removeLast();
        merged.add((last.$1, r.$2 > last.$2 ? r.$2 : last.$2));
      }
    }

    final highlightStyle = baseStyle.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700);

    final spans = <TextSpan>[];
    var pos = 0;
    for (final (start, end) in merged) {
      if (start > pos) {
        spans.add(TextSpan(text: text.substring(pos, start), style: baseStyle));
      }
      spans.add(TextSpan(text: text.substring(start, end), style: highlightStyle));
      pos = end;
    }
    if (pos < text.length) {
      spans.add(TextSpan(text: text.substring(pos), style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
