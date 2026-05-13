import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/worker.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  List<WorkerRecord> _workers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final workers = await ApiService.getWorkers();
      setState(() { _workers = workers; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _showDialog({WorkerRecord? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final suppCtrl = TextEditingController(
        text: existing != null ? existing.supplement.toStringAsFixed(0) : '');
    final minCtrl = TextEditingController(
        text: existing != null ? existing.minHourly.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'הוסף עובד' : 'עריכת עובד'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'שם עובד'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: suppCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'השלמה ₪ (לכל משמרת)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'שכר מינימום ₪ (לשעה)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final supp = double.tryParse(suppCtrl.text.trim()) ?? 0;
              final min = double.tryParse(minCtrl.text.trim()) ?? 0;
              if (name.isEmpty) return;
              Navigator.pop(context);
              if (existing == null) {
                await ApiService.addWorker(name, supp, min);
              } else {
                await ApiService.updateWorker(existing.id, name, supp, min);
              }
              _load();
            },
            child: const Text('שמור'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(WorkerRecord w) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('מחיקת עובד'),
        content: Text('למחוק את ${w.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('מחק', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteWorker(w.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('ניהול עובדים')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        backgroundColor: gold,
        foregroundColor: Colors.black,
        child: const Icon(Icons.person_add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _workers.isEmpty
              ? const Center(
                  child: Text('אין עובדים עדיין',
                      style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _workers.length,
                  itemBuilder: (_, i) {
                    final w = _workers[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(w.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('השלמה: ₪${w.supplement.toStringAsFixed(0)}',
                                style: TextStyle(color: gold)),
                            Text(
                                'שכר מינימום: ₪${w.minHourly.toStringAsFixed(0)}/שעה',
                                style: const TextStyle(color: Colors.white54)),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white54),
                              onPressed: () => _showDialog(existing: w),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _delete(w),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
