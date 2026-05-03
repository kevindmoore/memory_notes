import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/data/models.dart';
import 'package:memory_notes/features/notes/data/repositories.dart';

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
}
