import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:memory_notes/features/speech/application/speech_controller.dart';

class SpeechMicButton extends StatefulWidget {
  const SpeechMicButton({
    required this.controller,
    required this.speech,
    this.onError,
    this.iconSize = 20,
    this.appendToExistingText = true,
    this.autoStopAfterText = false,
    super.key,
  });

  final TextEditingController controller;
  final SpeechController speech;
  final ValueChanged<String>? onError;
  final double iconSize;
  final bool appendToExistingText;
  final bool autoStopAfterText;

  @override
  State<SpeechMicButton> createState() => _SpeechMicButtonState();
}

class _SpeechMicButtonState extends State<SpeechMicButton>
    with SingleTickerProviderStateMixin {
  final _owner = Object();
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  StreamSubscription<String>? _recognitionSub;
  StreamSubscription<void>? _completionSub;
  StreamSubscription<SpeechStatus>? _statusSub;
  Timer? _autoStopTimer;
  bool _isListening = false;
  String _baseText = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _statusSub = widget.speech.statusStream.listen((_) {
      final isOwnedSession = identical(widget.speech.activeOwner.value, _owner);
      final isOwnedListening = widget.speech.isListening && isOwnedSession;
      if (!isOwnedSession) {
        _finishListening();
        return;
      }
      if (_isListening == isOwnedListening || !mounted) {
        return;
      }
      setState(() {
        _isListening = isOwnedListening;
      });
    });
  }

  @override
  void dispose() {
    if (_isListening && identical(widget.speech.activeOwner.value, _owner)) {
      widget.speech.stopListening();
    }
    _autoStopTimer?.cancel();
    _recognitionSub?.cancel();
    _completionSub?.cancel();
    _statusSub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening || widget.speech.isListening) {
      await widget.speech.stopListening();
      _finishListening();
      return;
    }

    _baseText = widget.controller.text.trimRight();
    _attachSpeechSubscriptions();
    final started = await widget.speech.startListening(owner: _owner);
    if (!started) {
      _recognitionSub?.cancel();
      _recognitionSub = null;
      _completionSub?.cancel();
      _completionSub = null;
      final message = widget.speech.errorMessage.value ?? 'Speech recognition is unavailable.';
      widget.onError?.call(message);
      return;
    }

    setState(() {
      _isListening = true;
    });
  }

  void _attachSpeechSubscriptions() {
    _recognitionSub?.cancel();
    _recognitionSub = widget.speech.recognizedTextStream.listen((text) {
      if (!identical(widget.speech.activeOwner.value, _owner)) {
        return;
      }
      final nextText = _combineText(text);
      logMessage('SpeechMicButton applying recognized text: $nextText');
      _applyText(nextText);
      if (widget.autoStopAfterText && text.trim().isNotEmpty) {
        _autoStopTimer?.cancel();
        _autoStopTimer = Timer(const Duration(seconds: 2), () async {
          if (!_isListening || !identical(widget.speech.activeOwner.value, _owner)) {
            return;
          }
          await widget.speech.stopListening();
          _finishListening();
        });
      }
    });

    _completionSub?.cancel();
    _completionSub = widget.speech.completionStream.listen((_) {
      if (!identical(widget.speech.activeOwner.value, _owner) &&
          widget.speech.activeOwner.value != null) {
        return;
      }
      final finalText = widget.speech.lastRecognizedText.value.trim();
      if (finalText.isNotEmpty) {
        final nextText = _combineText(finalText);
        logMessage('SpeechMicButton applying completion text: $nextText');
        _applyText(nextText);
        Future<void>.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) {
            return;
          }
          if (widget.controller.text != nextText) {
            logMessage(
              'SpeechMicButton reapplying completion text after overwrite: '
              '${widget.controller.text} -> $nextText',
            );
            _applyText(nextText);
          }
        });
      }
      _finishListening();
    });
  }

  void _finishListening() {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    _recognitionSub?.cancel();
    _recognitionSub = null;
    _completionSub?.cancel();
    _completionSub = null;
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    } else {
      _isListening = false;
    }
  }

  String _combineText(String recognizedText) {
    final trimmedRecognition = _capitalizeFirstWord(recognizedText.trim());
    if (trimmedRecognition.isEmpty) {
      return _baseText;
    }
    if (!widget.appendToExistingText || _baseText.isEmpty) {
      return trimmedRecognition;
    }
    return '$_baseText $trimmedRecognition';
  }

  String _capitalizeFirstWord(String text) {
    if (text.isEmpty) {
      return text;
    }

    final firstChar = text[0];
    return '${firstChar.toUpperCase()}${text.substring(1)}';
  }

  void _applyText(String text) {
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _isListening ? Colors.red.shade600 : Theme.of(context).hintColor;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Transform.scale(
        scale: _isListening ? _scaleAnimation.value : 1,
        child: IconButton(
          tooltip: _isListening ? 'Stop dictation' : 'Start dictation',
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: iconColor,
            size: widget.iconSize,
          ),
          onPressed: _toggleListening,
        ),
      ),
    );
  }
}
