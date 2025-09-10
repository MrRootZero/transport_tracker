import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/passenger.dart';
import '../models/plan_type.dart';
import '../providers/passengers_provider.dart';

/// Screen for adding or editing a passenger.
class AddPassengerScreen extends ConsumerStatefulWidget {
  final Passenger? editing;
  const AddPassengerScreen({super.key, this.editing});

  @override
  ConsumerState<AddPassengerScreen> createState() => _AddPassengerScreenState();
}

class _AddPassengerScreenState extends ConsumerState<AddPassengerScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name;
  PlanType _plan = PlanType.daily;
  final _monthlyCtrl = TextEditingController();
  final _perTripCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editing?.name ?? '');
    _plan = widget.editing?.planType ?? PlanType.daily;
    _monthlyCtrl.text = widget.editing?.monthlyRate?.toString() ?? '';
    _perTripCtrl.text = widget.editing?.perTripRate?.toString() ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _monthlyCtrl.dispose();
    _perTripCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Passenger' : 'Add Passenger')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlanType>(
              value: _plan,
              items: PlanType.values.map((pt) {
                return DropdownMenuItem(
                  value: pt,
                  child: Text(switch (pt) {
                    PlanType.monthlyFull => 'Monthly - Full',
                    PlanType.monthlyMorning => 'Monthly - Morning Only',
                    PlanType.monthlyAfternoon => 'Monthly - Afternoon Only',
                    PlanType.daily => 'Daily Rate',
                  }),
                );
              }).toList(),
              onChanged: (v) => setState(() => _plan = v!),
              decoration: const InputDecoration(labelText: 'Plan Type'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monthlyCtrl,
              decoration: const InputDecoration(
                labelText: 'Monthly Rate (for monthly plans)',
                prefixText: 'R ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _perTripCtrl,
              decoration: const InputDecoration(
                labelText: 'Per Trip Rate (for daily plan, per session)',
                prefixText: 'R ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Save Changes' : 'Add Passenger'),
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                final monthly = double.tryParse(_monthlyCtrl.text.trim());
                final perTrip = double.tryParse(_perTripCtrl.text.trim());

                if (isEdit) {
                  final p = widget.editing!;
                  final updated = Passenger(
                    id: p.id,
                    name: _name.text.trim(),
                    planType: _plan,
                    monthlyRate: monthly,
                    perTripRate: perTrip,
                    active: p.active,
                    createdAt: p.createdAt,
                  );
                  await ref.read(passengersProvider.notifier).updatePassenger(updated);
                } else {
                  await ref.read(passengersProvider.notifier).addPassenger(
                        name: _name.text.trim(),
                        planType: _plan,
                        monthlyRate: monthly,
                        perTripRate: perTrip,
                      );
                }
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}