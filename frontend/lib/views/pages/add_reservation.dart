import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/models/no_slots_reason.dart';

import '../../providers/client_state_provider.dart';


class NewReservationScreen extends ConsumerStatefulWidget {
  const NewReservationScreen({super.key});

  @override
  ConsumerState<NewReservationScreen> createState() => _NewReservationScreen();
}

class _NewReservationScreen extends ConsumerState<NewReservationScreen> {
  DateTime? selectedDate;
  int numberOfGuests = 2;
  String? specialRequest;
  DateTime? selectedSlot;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final restaurant = ref
          .read(clientStateProvider)
          .value
          ?.currentRestaurant;
      if (restaurant != null) {
        ref.read(clientStateProvider.notifier)
            .loadFirstAvailableSlots(restaurant.id, numberOfGuests);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(clientStateProvider);
    final notifier = ref.read(clientStateProvider.notifier);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nouvelle réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message:
                'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (clientState) {
              return Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      clientState.currentRestaurant!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _pickDate(clientState),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Date'),
                                          Text(
                                            selectedDate != null
                                                ? DateFormat(
                                                'EEEE d/MM/yyyy', 'fr_FR')
                                                .format(selectedDate!)
                                                : (clientState.availableSlots
                                                ?.isNotEmpty == true
                                                ? DateFormat(
                                                'EEEE d/MM/yyyy', 'fr_FR')
                                                .format(
                                                clientState.availableSlots!
                                                    .first)
                                                : 'Choisir une date'),
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => _shiftDay(clientState, -1),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _shiftDay(clientState, 1),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const Divider(),
                    if(clientState.availableSlots == null)
                      const SizedBox.shrink()
                    else
                      if (clientState.availableSlots!.isEmpty &&
                          (clientState.noSlotsError == NoSlotsReason.closed
                              || clientState.noSlotsError ==
                                  NoSlotsReason.alreadyBookedService))
                        _warningBox(clientState.noSlotsError!)
                      else
                        ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Créneaux disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: (clientState.availableSlots ?? [])
                                .map((slot) =>
                                InkWell(
                                  onTap: () =>
                                      setState(() => selectedSlot = slot),
                                  borderRadius: BorderRadius.circular(16),
                                  child: _slotCard(slot, theme),
                                )
                            ).toList(),

                          )
                        ],
                    const SizedBox(height: 24),
                    if ((clientState.availableSlots?.isEmpty ?? false) &&
                        clientState.noSlotsError == NoSlotsReason.noCapacity)
                      _warningBox(clientState.noSlotsError!),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Nombre de convives'),
                      subtitle: Text(numberOfGuests.toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            //setState force le reload de la page
                            onPressed: numberOfGuests > 1
                                ? () => setState(() => numberOfGuests--)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: numberOfGuests < 10 ? () =>
                                setState(() => numberOfGuests++) : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Demandes spéciales (optionnel)',
                        border: OutlineInputBorder(),
                        hintText: 'Allergies, préférences...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Créer la réservation'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _slotCard(DateTime slot, ThemeData theme) {
    final isSelected = selectedSlot == slot;
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          DateFormat('HH:mm').format(slot),
          style: TextStyle(
            color: isSelected ? Colors.blue : theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(ClientState clientState) async {
    final restaurant = clientState.currentRestaurant;
    if (restaurant == null) return;


    /*si y a une selected date sinon si il y a des availableSlots, on affiche la date du premier slot(situation initiale
    si l'user n'a pas changé de date)*/
    final initial = selectedDate ??
        (clientState.availableSlots?.isNotEmpty == true ?
        clientState.availableSlots!.first : DateTime(2024, 12, 4));

    final selected = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2024, 12, 1),
        lastDate: DateTime(2025, 12, 31)
    );

    if (selected != null) {
      setState(() {
        selectedDate = selected;
        selectedSlot = null;
      });

      ref.read(clientStateProvider.notifier).loadSlotsPerDay(
          restaurant.id, selected, numberOfGuests);
    }
  }

  void _shiftDay(ClientState clientState, int delta) {
    final restaurant = clientState.currentRestaurant;
    if (restaurant == null) return;

    final base = selectedDate
        ?? (clientState.availableSlots?.isNotEmpty == true
            ? DateTime(clientState.availableSlots!.first.year,
            clientState.availableSlots!.first.month,
            clientState.availableSlots!.first.day)
            : DateTime(2024, 12, 4));

    final newDate = DateTime(base.year, base.month, base.day + delta);

    setState(() {
      selectedDate = newDate;
      selectedSlot = null;
    });
    ref.read(clientStateProvider.notifier)
        .loadSlotsPerDay(restaurant.id, newDate, numberOfGuests);
  }

  Widget _warningBox(NoSlotsReason reason) {
    String message;
    switch (reason) {
      case NoSlotsReason.closed:
        message = 'Le restaurant est fermé ce jour-là.';
        break;
      case NoSlotsReason.alreadyBookedService:
        message =
        'Vous avez déjà une réservation pour tous les services de ce jour.';
        break;
      case NoSlotsReason.noCapacity:
        message =
        'La capacité du restaurant est insuffisante pour le nombre de convives demandé.';
        break;
    }

    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child:Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
    );
  }
}
