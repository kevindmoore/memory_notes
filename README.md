# memory_notes

Memory Notes is a Flutter note and task organizer for keeping related information together in a simple workspace.

The app is built around a three-level structure:

- Lists hold broad areas of work or life.
- Categories group related notes inside each list.
- Tasks live inside categories and can include child tasks and supporting notes.

This makes it useful for planning projects, capturing reference material, and keeping action items connected to the notes that explain them.

`memory_notes` supports both mobile and desktop layouts. On mobile, the app uses a stacked navigation flow for moving from lists to categories to tasks. On desktop, it provides a split workspace so you can browse lists, drill into tasks, and edit task notes side by side.

The app also includes:

- Search across lists, categories, and tasks
- Task notes with autosave
- Realtime syncing through Supabase
- Speech dictation for faster note entry
- Duplicate and rename actions for key note structures

## Local Environment Setup

Copy `dart_defines/environment.example.json` to `dart_defines/environment.json`, replace `SENTRY_DSN` with the DSN from the Sentry Flutter project, set `FIREBASE_APPCHECK_WEB_SITE_KEY` to the reCAPTCHA v3 site key for web release builds, and optionally set `FIREBASE_APPCHECK_WEB_DEBUG_TOKEN` or `FIREBASE_APPCHECK_APPLE_DEBUG_TOKEN` to Firebase App Check debug tokens for local debug runs. Then include it in release builds/runs:

```sh
flutter run --release --dart-define-from-file=dart_defines/environment.json
```

Sentry is disabled in debug and profile builds.

If Sentry events do not appear, temporarily set `SENTRY_DIAGNOSTIC_LOGS` to `true` in `dart_defines/environment.json` and rerun the release command to print Sentry SDK transport diagnostics.

Overall, the goal of Memory Notes is to make note-taking and task tracking feel connected instead of separate, so the context for a task is always close at hand.
