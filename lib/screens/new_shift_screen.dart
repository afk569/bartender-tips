import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/worker.dart';

class NewShiftScreen extends StatefulWidget {
  const NewShiftScreen({super.key});

  @override
  State<NewShiftScreen> createState() => _NewShiftScreenState();
}

class _NewShiftScreenState extends State<NewShiftScreen> {
  final _totalController = TextEditingController();
  List<WorkerRecord> _allWorkers = [];
  final List<_ShiftWorkerEntry> _entries = [];
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _loading = true);
    try {
      final workers = await ApiService.getWorkers();
      setState(() {
        _allWorkers = workers;
        // Pre-fill all workers as entries
        _entries.clear();
        for (final w in workers) {
          _entries.add(_ShiftWorkerEntry(name: w.name));
        }
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickTime(BuildContext context, _ShiftWorkerEntry entry, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStart) entry.startTime = formatted;
        else entry.endTime = formatted;
      });
    }
  }

  Future<void> _submit() async {
    final totalText = _totalController.text.trim();
    if (totalText.isEmpty) {
      _showError('נא להזין סכום טיפים');
      return;
    }
    final total = double.tryParse(totalText);
    if (total == null || total <= 0) {
      _showError('סכום לא תקין');
      return;
    }

    final activeEntries = _entries.where((e) => e.active).toList();
    if (activeEntries.isEmpty) {
      _showError('נא לבחור לפחות עובד אחד');
      return;
    }
    for (final e in activeEntries) {
      if (e.startTime == null || e.endTime == null) {
        _showError('נא להזין שעות לכל עובד פעיל');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final workers = activeEntries.map((e) => Worker(
        name: e.name,
        startTime: e.startTime!,
        endTime: e.endTime!,
      )).toList();

      await ApiService.calculateShift(total, workers);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('שגיאה: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('משמרת חדשה')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Total tips input ──
                      TextField(
                        controller: _totalController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'סה"כ טיפים שהתקבלו ₪',
                          prefixText: '₪ ',
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('עובדים במשמרת',
                          style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),

                      // ── Worker rows ──
                      ..._entries.map((e) => _workerRow(e)),
                    ],
                  ),
                ),

                // ── Submit button ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('חשב ושמור משמרת'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _workerRow(_ShiftWorkerEntry entry) {
    final gold = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.active ? gold.withOpacity(0.4) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Active toggle
          Switch(
            value: entry.active,
            activeColor: gold,
            onChanged: (v) => setState(() => entry.active = v),
          ),
          const SizedBox(width: 8),

          // Name
          Expanded(
            child: Text(entry.name,
                style: TextStyle(
                  color: entry.active ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                )),
          ),

          // Times (only if active)
          if (entry.active) ...[
            _timeButton(entry.startTime ?? 'כניסה', () => _pickTime(context, entry, true)),
            const SizedBox(width: 6),
            _timeButton(entry.endTime ?? 'יציאה', () => _pickTime(context, entry, false)),
          ],
        ],
      ),
    );
  }

  Widget _timeButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 13)),
    ),
  );
}

class _ShiftWorkerEntry {
  final String name;
  bool active;
  String? startTime;
  String? endTime;

  _ShiftWorkerEntry({required this.name, this.active = true});
}
