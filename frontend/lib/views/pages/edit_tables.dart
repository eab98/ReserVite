import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/providers/manager_state_provider.dart';
import 'package:prbd_2526_a03/views/widgets/time_travel_widget.dart';

import '../../models/tables.dart';



class EditTableScreen extends ConsumerStatefulWidget {
  final Tables? table;
  const EditTableScreen({super.key, required this.table});

  @override
  ConsumerState<EditTableScreen> createState() => _EditTableScreen();
}


class _EditTableScreen extends ConsumerState<EditTableScreen>{
  bool get isEdit => widget.table != null;
  final _tableNumberController = TextEditingController();
  int capacity = 2;


  @override
  void initState(){
    super.initState();
    Future.microtask(() async {
      if(isEdit){

        setState(() {
          _tableNumberController.text = (widget.table!.tableNumber).toString();
          capacity = widget.table!.capacity;
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minNeeded = widget.table?.minCapacityNeeded ?? 0;
    final limit = minNeeded > 1 ? minNeeded : 1;
    final atLimit = capacity <= limit;


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(isEdit ? 'Modifier la table' : 'Nouvelle table'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: () =>  _saveTable(),
            icon: const Icon(Icons.save),
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
              child: TimeTravelWidget(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tableNumberController,
                  decoration:  const InputDecoration(
                    labelText: 'Numéro de table',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Capacité'),
                Row(
                  children: [
                      Tooltip(
                      message: atLimit ? (isEdit ? 'Impossible de diminuer la capacité : une ou plusieurs résa utilisent cette table et nécessitent au moins cette capacité'
                      : 'Capacité minimale (1 personne)')
                      : '',
                  child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: atLimit
                        ? null
                        : () => setState(() => capacity = capacity - 1),
                  ),
                ),

                     Text(
                      '$capacity personnes',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() {
                        capacity = capacity + 1;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTable() async{
    final table = widget.table;
    final notifier = ref.read(managerStateProvider.notifier);
    final number = int.tryParse(_tableNumberController.text);
    if (number == null) {
      return;
    }

    try {
      if (table == null) {
        await notifier.saveTable(number, capacity, null);
      } else {
        await notifier.saveTable(number, capacity, table.id);
      }
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Table sauvegardée avec succès'), backgroundColor: Colors.green));
      // notifier.loadTables();
      if (!mounted) return;
      Navigator.pop(context);


    }catch (e){
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
}
