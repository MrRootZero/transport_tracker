import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/session.dart';

/// Represents the parsed result of a voice command.
class ParsedVoiceCommand {
  final String? passengerName;
  final Session? session;
  final DateTime date;
  final bool both;

  ParsedVoiceCommand({
    required this.passengerName,
    required this.session,
    required this.date,
    this.both = false,
  });
}

/// Service for handling speech recognition and parsing commands.
class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Check if speech recognition is available.
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }

  /// Listen once and return the recognized words.
  Future<String?> listenOnce() async {
    final available = await _speech.initialize();
    if (!available) return null;

    final completer = Completer<String?>();
    String buffer = '';

    _speech.listen(
      onResult: (res) {
        buffer = res.recognizedWords;
        if (res.finalResult) {
          _speech.stop();
          completer.complete(buffer);
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: 'en_ZA',
    );

    return completer.future;
  }

  /// Parse a spoken command into passenger name, session(s), and date.
  ParsedVoiceCommand parse(String text, List<String> knownNames) {
    final lower = text.toLowerCase();

    // Identify passenger name by matching known names.
    String? nameMatch;
    for (final n in knownNames) {
      if (lower.contains(n.toLowerCase())) {
        nameMatch = n;
        break;
      }
    }

    // Detect sessions from keywords.
    final hasMorning = lower.contains('morning');
    final hasAfternoon = lower.contains('afternoon');
    final both = lower.contains('both') || (hasMorning && hasAfternoon);

    Session? session;
    if (!both) {
      if (hasMorning) session = Session.morning;
      if (hasAfternoon) session = Session.afternoon;
    }

    // Determine date: default today; allow "yesterday".
    DateTime date = DateTime.now();
    if (lower.contains('yesterday')) {
      date = DateTime.now().subtract(const Duration(days: 1));
    }

    return ParsedVoiceCommand(
      passengerName: nameMatch,
      session: session,
      date: date,
      both: both,
    );
  }
}