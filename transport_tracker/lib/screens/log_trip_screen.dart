import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/passengers_provider.dart';
import '../providers/trips_provider.dart';
import '../models/session.dart';
import '../models/passenger.dart';
import '../services/voice_service.dart';

/// Screen for logging trips manually or via voice.
class LogTripScreen extends ConsumerStatefulWidget {
  const LogTripScreen({super.key});

  @override
  ConsumerState<LogTripScreen> createState() => _LogTripScreenState();
}

class _LogTripScreenState extends ConsumerState<LogTripScreen> {
  String? _selectedPassengerId;
  DateTime _date = DateTime.now();
  Session _session = Session.morning;
  final _voice = VoiceService();
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    final passengers = ref.watch(passengersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Log Trip')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _selectedPassengerId,
            items: passengers
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedPassengerId = v),
            decoration: const InputDecoration(labelText: 'Passenger'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Session>(
                  value: _session,
                  items: const [
                    DropdownMenuItem(
                        value: Session.morning, child: Text('Morning')),
                    DropdownMenuItem(
                        value: Session.afternoon, child: Text('Afternoon')),
                  ],
                  onChanged: (v) => setState(() => _session = v!),
                  decoration: const InputDecoration(labelText: 'Session'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                      initialDate: _date,
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Log Selected Trip'),
            onPressed: () async {
              if (_selectedPassengerId == null) return;
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(tripsProvider.notifier).logTrip(
                    passengerId: _selectedPassengerId!,
                    date: _date,
                    session: _session,
                  );
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Trip logged')),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.all_inclusive),
                  label: const Text('Log BOTH (today)'),
                  onPressed: () async {
                    if (_selectedPassengerId == null) return;
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(tripsProvider.notifier).logBoth(
                          passengerId: _selectedPassengerId!,
                          date: DateTime.now(),
                        );
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Both sessions logged')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                  label: Text(_listening ? 'Listening…' : 'Voice Log'),
                  onPressed: () async {
                    setState(() => _listening = true);
                    final messenger = ScaffoldMessenger.of(context);
                    final available = await _voice.isAvailable();
                    if (!available) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Speech not available')),
                      );
                      setState(() => _listening = false);
                      return;
                    }
                    final spoken = await _voice.listenOnce();
                    setState(() => _listening = false);
                    if (spoken == null || spoken.trim().isEmpty) return;

                    final knownNames = passengers.map((p) => p.name).toList();
                    final parsed = _voice.parse(spoken, knownNames);

                    // Resolve the spoken name to a matching Passenger, if any.
                    Passenger? match;
                    if (passengers.isEmpty) {
                      match = null;
                    } else {
                      try {
                        match = passengers.firstWhere(
                          (p) =>
                              p.name.toLowerCase() ==
                              (parsed.passengerName ?? '').toLowerCase(),
                        );
                      } catch (_) {
                        // No matching passenger found
                        match = null;
                      }
                    }
                    // If no match, do nothing.
                    if (match == null) return;

                    if (parsed.both) {
                      await ref.read(tripsProvider.notifier).logBoth(
                            passengerId: match.id,
                            date: parsed.date,
                          );
                    } else if (parsed.session != null) {
                      await ref.read(tripsProvider.notifier).logTrip(
                            passengerId: match.id,
                            date: parsed.date,
                            session: parsed.session!,
                          );
                    } else {
                      // fallback: default morning
                      await ref.read(tripsProvider.notifier).logTrip(
                            passengerId: match.id,
                            date: parsed.date,
                            session: Session.morning,
                          );
                    }

                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                          content: Text('Logged for ${match.name}: "$spoken"')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
