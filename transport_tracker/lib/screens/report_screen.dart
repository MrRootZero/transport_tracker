import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/passengers_provider.dart';
import '../providers/trips_provider.dart';
import '../utils/date_utils.dart';
import '../utils/currency.dart';
import '../models/session.dart';

/// Defines the selectable report ranges.
enum ReportRange { week, month }

/// Screen showing weekly or monthly reports per passenger.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportRange _range = ReportRange.week;
  DateTime _anchor = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final passengers = ref.watch(passengersProvider);

    final from = _range == ReportRange.week ? startOfWeek(_anchor) : startOfMonth(_anchor);
    final to = _range == ReportRange.week ? endOfWeek(_anchor) : endOfMonth(_anchor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          PopupMenuButton<ReportRange>(
            initialValue: _range,
            onSelected: (v) => setState(() => _range = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: ReportRange.week, child: Text('This Week')),
              PopupMenuItem(value: ReportRange.month, child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: passengers.isEmpty
          ? const Center(child: Text('No data'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: passengers.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (ctx, i) {
                final p = passengers[i];
                final counts = ref.read(tripsProvider.notifier).sessionCountsForPassenger(
                  passengerId: p.id,
                  from: from,
                  to: to,
                );
                final amount = ref.read(tripsProvider.notifier).amountOwedForPassenger(
                  passenger: p,
                  from: from,
                  to: to,
                );

                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                      'Morning: ${counts[Session.morning] ?? 0} • Afternoon: ${counts[Session.afternoon] ?? 0}'),
                  trailing: Text(
                    money(amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}