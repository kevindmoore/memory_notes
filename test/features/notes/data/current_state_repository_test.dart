import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CurrentStateRepository.selectLatestCurrentState', () {
    test('returns the newest row for the current user', () {
      final selected = CurrentStateRepository.selectLatestCurrentState(
        [
          CurrentState(
            id: 1,
            userId: 'user-a',
            currentFiles: '{"openFileIds":[1]}',
            lastUpdated: DateTime(2026, 4, 4, 9),
          ),
          CurrentState(
            id: 2,
            userId: 'user-b',
            currentFiles: '{"openFileIds":[2]}',
            lastUpdated: DateTime(2026, 4, 4, 12),
          ),
          CurrentState(
            id: 3,
            userId: 'user-a',
            currentFiles: '{"openFileIds":[3,4]}',
            lastUpdated: DateTime(2026, 4, 4, 13),
          ),
        ],
        currentUserId: 'user-a',
      );

      expect(selected?.id, 3);
      expect(selected?.userId, 'user-a');
    });

    test('falls back to the highest id when timestamps are missing', () {
      final selected = CurrentStateRepository.selectLatestCurrentState(
        [
          const CurrentState(
            id: 4,
            userId: 'user-a',
            currentFiles: '{"openFileIds":[1]}',
          ),
          const CurrentState(
            id: 7,
            userId: 'user-a',
            currentFiles: '{"openFileIds":[2,3]}',
          ),
        ],
        currentUserId: 'user-a',
      );

      expect(selected?.id, 7);
    });

    test('returns null when there is no row for the current user', () {
      final selected = CurrentStateRepository.selectLatestCurrentState(
        [
          const CurrentState(
            id: 1,
            userId: 'user-b',
            currentFiles: '{"openFileIds":[1]}',
          ),
        ],
        currentUserId: 'user-a',
      );

      expect(selected, isNull);
    });
  });

  group('DeviceWorkspaceStateRepository', () {
    test('falls back to legacy device workspace state when user-scoped state is empty', () async {
      SharedPreferences.setMockInitialValues({
        'device_workspace_state': '{"openFileIds":[1,2,3],"selectedFileId":2}',
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = DeviceWorkspaceStateRepository(
        currentUserId: () => 'user-a',
        prefs: prefs,
      );

      final state = await repository.getWorkspaceState();

      expect(state.openFileIds, [1, 2, 3]);
      expect(state.selectedFileId, 2);
    });

    test('prefers user-scoped device workspace state when it exists', () async {
      SharedPreferences.setMockInitialValues({
        'device_workspace_state': '{"openFileIds":[1,2,3],"selectedFileId":2}',
        'device_workspace_state_user-a': '{"openFileIds":[4],"selectedFileId":4}',
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = DeviceWorkspaceStateRepository(
        currentUserId: () => 'user-a',
        prefs: prefs,
      );

      final state = await repository.getWorkspaceState();

      expect(state.openFileIds, [4]);
      expect(state.selectedFileId, 4);
    });
  });
}
