import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/notes/application/notes_mobile_store.dart';
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
    required this.noteDetailActions,
    required this.noteEditActions,
    required this.speech,
    super.key,
  });
  final SearchStore search;
  final NotesMobileStore notesMobile;
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

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => _query.value = _searchCtrl.text.trim().toLowerCase(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPreload) return;
    _didPreload = true;
    widget.search.preload();
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
                suffixIcon: Watch((context) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpeechMicButton(
                          controller: _searchCtrl,
                          speech: widget.speech,
                          appendToExistingText: false,
                          onError: (message) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          ),
                        ),
                        if (_query.value.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textDisabled, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _query.value = '';
                            },
                          ),
                      ],
                    )),
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
            child: Watch((context) {
              if (widget.search.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              final q = _query.value;

              if (q.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, size: 56, color: AppColors.textDisabled),
                      SizedBox(height: 16),
                      Text('Search your notes',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      SizedBox(height: 6),
                      Text('Type to find lists, categories and tasks',
                          style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
                    ],
                  ),
                );
              }

              final results = widget.search.buildResults(q);

              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textDisabled),
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
                      const Text('Try a different search term',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                itemCount: results.length,
                itemBuilder: (context, i) => _buildResultTile(context, results[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResultItem result) {
    return switch (result) {
      SearchFileResultItem(file: final f) => ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_rounded, color: AppColors.accent, size: 20),
          ),
          title: _HighlightedText(text: f.name, query: _query.value),
          subtitle:
              const Text('List', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
          onTap: () => context.pushRoute(
            NoteDetailRoute(
              fileId: f.id!,
              notesMobile: widget.notesMobile,
              noteDetailActions: widget.noteDetailActions,
              noteEditActions: widget.noteEditActions,
              speech: widget.speech,
            ),
          ),
        ),
      SearchCategoryResultItem(category: final c, parentFile: final f, subtitle: final subtitle) =>
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
          title: _HighlightedText(text: c.name, query: _query.value),
          subtitle: Text(subtitle,
              style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
          onTap: () => context.pushRoute(
            NoteEditRoute(
              fileId: f.id!,
              categoryId: c.id!,
              notesMobile: widget.notesMobile,
              noteEditActions: widget.noteEditActions,
              speech: widget.speech,
            ),
          ),
        ),
      SearchTodoResultItem(
        todo: final t,
        parentCategory: final c,
        parentFile: final f,
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
              t.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: t.done ? AppColors.accent : AppColors.textDisabled,
              size: 20,
            ),
          ),
          title: _HighlightedText(text: t.name, query: _query.value),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
          ),
          onTap: () => context.pushRoute(
            NoteEditRoute(
              fileId: f.id!,
              categoryId: c.id!,
              parentTodoId: t.parentTodoId,
              focusedTodoId: t.id,
              openFocusedTodoNotes: true,
              notesMobile: widget.notesMobile,
              noteEditActions: widget.noteEditActions,
              speech: widget.speech,
            ),
          ),
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Highlights the matching portion of text in accent color
// ---------------------------------------------------------------------------

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: const TextStyle(color: AppColors.textPrimary));
    }

    final lower = text.toLowerCase();
    final idx = lower.indexOf(query);
    if (idx == -1) {
      return Text(text, style: const TextStyle(color: AppColors.textPrimary));
    }

    return RichText(
      text: TextSpan(
        children: [
          if (idx > 0)
            TextSpan(
              text: text.substring(0, idx),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (idx + query.length < text.length)
            TextSpan(
              text: text.substring(idx + query.length),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
        ],
      ),
    );
  }
}
