import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/plan_type.dart';
import 'models/session.dart';
import 'models/passenger.dart';
import 'models/trip_entry.dart';

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(PlanTypeAdapter())
    ..registerAdapter(SessionAdapter())
    ..registerAdapter(PassengerAdapter())
    ..registerAdapter(TripEntryAdapter());
  await Hive.openBox<Passenger>('passengers');
  await Hive.openBox<TripEntry>('trips');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();
  runApp(const ProviderScope(child: TransportApp()));
}