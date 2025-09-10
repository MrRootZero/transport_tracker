import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_entry.dart';
import '../models/session.dart';
import '../models/passenger.dart';
import '../models/plan_type.dart';
import '../utils/date_utils.dart';

/// Provides access to the Hive box storing trip entries.
final tripsBoxProvider = Provider<Box<TripEntry>>((ref) {
  return Hive.box<TripEntry>('trips');
});

/// State provider for all trip entries.
final tripsProvider =
    StateNotifierProvider<TripsNotifier, List<TripEntry>>((ref) {
  final box = ref.watch(tripsBoxProvider);
  return TripsNotifier(box);
});

/// Manages trip logging and reporting logic.
class TripsNotifier extends StateNotifier<List<TripEntry>> {
  final Box<TripEntry> _box;

  TripsNotifier(this._box) : super(_box.values.toList()) {
    _box.watch().listen((_) => _reload());
  }

  void _reload() => state = _box.values.toList();

  /// Log a single session for a passenger.
  Future<void> logTrip({
    required String passengerId,
    required DateTime date,
    required Session session,
  }) async {
    final id = const Uuid().v4();
    final entry = TripEntry(
      id: id,
      passengerId: passengerId,
      date: dateOnly(date),
      session: session,
    );
    await _box.put(id, entry);
    _reload();
  }

  /// Helper to log both sessions (morning and afternoon) on the same date.
  Future<void> logBoth({
    required String passengerId,
    required DateTime date,
  }) async {
    await logTrip(passengerId: passengerId, date: date, session: Session.morning);
    await logTrip(passengerId: passengerId, date: date, session: Session.afternoon);
  }

  /// Calculate the total amount owed by a passenger in a date range.
  double amountOwedForPassenger({
    required Passenger passenger,
    required DateTime from,
    required DateTime to,
  }) {
    final entries = state.where(
      (e) =>
          e.passengerId == passenger.id &&
          !e.date.isBefore(dateOnly(from)) &&
          !e.date.isAfter(dateOnly(to)),
    );

    switch (passenger.planType) {
      case PlanType.monthlyFull:
      case PlanType.monthlyMorning:
      case PlanType.monthlyAfternoon:
        // Monthly plan pays a fixed monthly rate if the window overlaps that month.
        return passenger.monthlyRate ?? 0.0;

      case PlanType.daily:
        final per = passenger.perTripRate ?? 0.0;
        final count = entries.length; // each entry is one session
        return per * count;
    }
  }

  /// Count sessions by type for a passenger in a date range.
  Map<Session, int> sessionCountsForPassenger({
    required String passengerId,
    required DateTime from,
    required DateTime to,
  }) {
    final entries = state.where(
      (e) =>
          e.passengerId == passengerId &&
          !e.date.isBefore(dateOnly(from)) &&
          !e.date.isAfter(dateOnly(to)),
    );
    final morning = entries.where((e) => e.session == Session.morning).length;
    final afternoon = entries.where((e) => e.session == Session.afternoon).length;
    return {Session.morning: morning, Session.afternoon: afternoon};
  }
}