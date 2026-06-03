import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../providers/client_state_provider.dart';

class ReservationDetailsScreen extends ConsumerStatefulWidget {
  final int id;
  const ReservationDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<ReservationDetailsScreen> createState() => _ReservationDetailsScreen();
  }

class _ReservationDetailsScreen extends ConsumerState<ReservationDetailsScreen> {


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
          //les vues sont superposées en un stack donc faire un pop revele la vue d'avant ici my_reservations
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => notifier.loadReservationDetails(widget.id)
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
            data: (clientState){
              final details = clientState.currentReservationDetails;
              if(details == null) {
                return const Center(child: Text('Aucune réservation sélectionnée'));
              }
              return details.when(
                  data: (r) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.restaurant),
                                  const SizedBox(width: 8),
                                   Expanded(
                                    child: Text(
                                      r.restoName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                   SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${r.restoAddress!},${r.city}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    r.restoPhone!,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Date: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(r.dateTime)} '
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Heure: ${DateFormat('HH:mm').format(r.dateTime)}'),                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people, size: 20),
                                  const SizedBox(width: 8),
                                   Text('Nombre de convives:${r.numberOfGuests}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.info, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Statut: '),
                                  _statusIcon(r.status),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text(
                                'Demandes spéciales',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r.specialRequests ?? 'Aucune demande',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
                              label: const Text('Modifier'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.cancel),
                              label: const Text('Annuler'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  loading: () => const Center(child: CircularProgressIndicator()));
            },
            error: (e, _) => Center(child: Text('Erreur: $e')),
            loading: () => const Center(child: CircularProgressIndicator()))
      ),
    ),
    );
  }

  Widget _statusIcon(String status){
    switch (status) {
      case 'pending':
    return Chip(
    label: const Text(
    'En attente',
    style: TextStyle(fontSize: 12, color: Colors.white),
    ),
    backgroundColor: const Color(0xFFFF9800),
    padding: EdgeInsets.zero,
    );
      case 'confirmed':
        return Chip(
    label: const Text(
    'Confirmée',
    style: TextStyle(fontSize: 12, color: Colors.white),
    ),
    backgroundColor:  Colors.green,
    padding: EdgeInsets.zero,
    );
      case 'cancelled':
        return Chip(
      label: const Text(
      'Annulée',
      style: TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor:  Colors.red,
      padding: EdgeInsets.zero,
    );
      case 'completed':
        return Chip(
          label: const Text(
            'Terminée',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor:  Colors.blue,
          padding: EdgeInsets.zero,
        );
      default:
        return const Icon(Icons.help);
    }
  }
}
