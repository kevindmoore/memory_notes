import 'dart:async';

import 'package:lumberdash/lumberdash.dart';
import 'package:signals/signals.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum SpeechStatus {
  idle,
  listening,
  error,
}

class SpeechController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final _recognizedTextController = StreamController<String>.broadcast();
  final _completionController = StreamController<void>.broadcast();
  final _statusController = StreamController<SpeechStatus>.broadcast();

  final isInitialized = signal(false);
  final isAvailable = signal(true);
  final status = signal(SpeechStatus.idle);
  final activeOwner = signal<Object?>(null);
  final lastRecognizedText = signal('');
  final errorMessage = signal<String?>(null);

  Stream<String> get recognizedTextStream => _recognizedTextController.stream;
  Stream<void> get completionStream => _completionController.stream;
  Stream<SpeechStatus> get statusStream => _statusController.stream;

  bool get isListening => status.value == SpeechStatus.listening;

  Future<bool> initialize() async {
    if (isInitialized.value) {
      return isAvailable.value;
    }

    try {
      final available = await _speech.initialize(
        onError: (error) {
          logError('SpeechController error: ${error.errorMsg}');
          _setError(error.errorMsg);
        },
        onStatus: (nextStatus) {
          logMessage('SpeechController status: $nextStatus');
          if (nextStatus == 'done' || nextStatus == 'notListening') {
            _setStatus(SpeechStatus.idle);
            Future<void>.delayed(const Duration(milliseconds: 1000), () {
              if (status.value == SpeechStatus.idle &&
                  lastRecognizedText.value.trim().isNotEmpty) {
                _completionController.add(null);
                activeOwner.value = null;
              }
            });
          }
        },
      );

      isInitialized.value = true;
      isAvailable.value = available;
      if (!available) {
        _setError('Speech recognition is not available on this device.');
      }
      return available;
    } catch (error) {
      logError('SpeechController.initialize: $error');
      isInitialized.value = true;
      isAvailable.value = false;
      _setError('Failed to initialize speech recognition.');
      return false;
    }
  }

  Future<bool> startListening({Object? owner}) async {
    final available = await initialize();
    if (!available) {
      return false;
    }

    try {
      if (isListening) {
        await stopListening();
      }

      lastRecognizedText.value = '';
      errorMessage.value = null;
      activeOwner.value = owner;
      _setStatus(SpeechStatus.listening);

      await _speech.listen(
        onResult: (result) {
          final text = result.recognizedWords;
          logMessage('SpeechController recognized text: $text');
          lastRecognizedText.value = text;
          _recognizedTextController.add(text);
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
        ),
      );

      return true;
    } catch (error) {
      logError('SpeechController.startListening: $error');
      _setError('Failed to start speech recognition.');
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
      activeOwner.value = null;
      _setStatus(SpeechStatus.idle);
    } catch (error) {
      logError('SpeechController.stopListening: $error');
      _setError('Failed to stop speech recognition.');
    }
  }

  void reset() {
    activeOwner.value = null;
    _setStatus(SpeechStatus.idle);
    lastRecognizedText.value = '';
    errorMessage.value = null;
  }

  void dispose() {
    _recognizedTextController.close();
    _completionController.close();
    _statusController.close();
    _speech.cancel();
  }

  void _setError(String message) {
    activeOwner.value = null;
    _setStatus(SpeechStatus.error);
    errorMessage.value = message;
  }

  void _setStatus(SpeechStatus nextStatus) {
    status.value = nextStatus;
    _statusController.add(nextStatus);
  }
}
