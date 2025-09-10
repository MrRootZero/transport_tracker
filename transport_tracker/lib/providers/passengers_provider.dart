import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/passenger.dart';
import '../models/plan_type.dart';

/// Provides access to the Hive box storing passengers.
final passengersBoxProvider = Provider<Box<Passenger>>((ref) {
  return Hive.box<Passenger>('passengers');
});

/// State provider for all passengers.
final passengersProvider =
    StateNotifierProvider<PassengersNotifier, List<Passenger>>((ref) {
  final box = ref.watch(passengersBoxProvider);
  return PassengersNotifier(box);
});

/// Manages CRUD operations on passengers.
class PassengersNotifier extends StateNotifier<List<Passenger>> {
  final Box<Passenger> _box;

  PassengersNotifier(this._box) : super(_box.values.toList()) {
    _box.watch().listen((_) => _reload());
  }

  void _reload() => state = _box.values.toList();

  Passenger? getById(String id) {
    try {
      return _box.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addPassenger({
    required String name,
    required PlanType planType,
    double? monthlyRate,
    double? perTripRate,
  }) async {
    final id = const Uuid().v4();
    final p = Passenger(
      id: id,
      name: name.trim(),
      planType: planType,
      monthlyRate: monthlyRate,
      perTripRate: perTripRate,
    );
    await _box.put(id, p);
    _reload();
  }

  Future<void> updatePassenger(Passenger p) async {
    await _box.put(p.id, p);
    _reload();
  }

  Future<void> deletePassenger(String id) async {
    await _box.delete(id);
    _reload();
  }
}