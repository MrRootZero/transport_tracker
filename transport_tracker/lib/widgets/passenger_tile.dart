import 'package:flutter/material.dart';
import '../models/passenger.dart';
import '../models/plan_type.dart';
import '../utils/currency.dart';

/// List tile displaying a passenger's info with edit/delete actions.
class PassengerTile extends StatelessWidget {
  final Passenger passenger;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PassengerTile({
    super.key,
    required this.passenger,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final planText = switch (passenger.planType) {
      PlanType.monthlyFull => 'Monthly (Full)',
      PlanType.monthlyMorning => 'Monthly (Morning)',
      PlanType.monthlyAfternoon => 'Monthly (Afternoon)',
      PlanType.daily => 'Daily',
    };
    final rateText = switch (passenger.planType) {
      PlanType.daily => 'Per trip: ${money(passenger.perTripRate ?? 0)}',
      _ => 'Monthly: ${money(passenger.monthlyRate ?? 0)}',
    };

    return Card(
      child: ListTile(
        title: Text(passenger.name),
        subtitle: Text('$planText • $rateText'),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}