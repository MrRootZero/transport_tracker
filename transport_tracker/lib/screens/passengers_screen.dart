import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/passengers_provider.dart';
import 'add_passenger_screen.dart';
import '../widgets/passenger_tile.dart';

/// Screen for listing and managing passengers.
class PassengersScreen extends ConsumerWidget {
  const PassengersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengers = ref.watch(passengersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Passengers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPassengerScreen()),
          );
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      body: passengers.isEmpty
          ? const Center(child: Text('No passengers yet'))
          : ListView.builder(
              itemCount: passengers.length,
              itemBuilder: (ctx, i) {
                final p = passengers[i];
                return PassengerTile(
                  passenger: p,
                  onDelete: () =>
                      ref.read(passengersProvider.notifier).deletePassenger(p.id),
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddPassengerScreen(editing: p),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}