import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/worker.dart';
import 'new_shift_screen.dart';
import 'workers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ShiftResult> _shifts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    setState(() => _loading = true);
    try {
      final shifts = await ApiService.getShifts();
      setState(() { _shifts = shifts; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteShift(int id) async {
    await ApiService.deleteShift(id);
    _loadShifts();
  }

  // ── Supplement breakdown popup ────────────────────────────────────────────
  void _showSupplementBreakdown(BuildContext context, WorkerResult w) {
    final gold = Theme.of(context).colorScheme.primary;
    final bool hasGap = w.hourlyGap > 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.calculate_outlined, color: gold, size: 20),
            const SizedBox(width: 8),
            Text('חישוב השלמה — ${w.name}',
                style: TextStyle(color: gold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. נתונים בסיסיים
            _breakdownRow('שעות עבודה', w.hoursWorked.toStringAsFixed(2), Colors.white70),
            _breakdownRow('טיפ לשעה', '₪${w.tipPerHour.floor()}', Colors.white70),
            
            // 2. שורת חישוב סה"כ טיפים (בדומה לתוספת מינימום)
            _breakdownRow(
              'טיפים סה"כ',
              '${w.hoursWorked.toStringAsFixed(2)} × ₪${w.tipPerHour.floor()} = ₪${w.tipAmount.floor()}',
              Colors.white,
              bold: true,
            ),
            
            const Divider(color: Colors.white12, height: 24),
            
            // 3. הגדרות שכר
            _breakdownRow('שכר מינימום', '₪${w.minHourly.floor()}/שעה', Colors.white70),
            _breakdownRow('השלמה בסיסית', '₪${w.baseSupplement.floor()}', Colors.white70),
            
            const Divider(color: Colors.white12, height: 24),
            
            // 4. חישוב פער
            if (hasGap) ...[
              _breakdownRow(
                'פער שעתי',
                '₪${w.minHourly.floor()} - ₪${w.tipPerHour.floor()} = ₪${w.hourlyGap.floor()}/שעה',
                Colors.orangeAccent,
              ),
              _breakdownRow(
                'תוספת מינימום',
                '₪${w.hourlyGap.floor()} × ${w.hoursWorked.toStringAsFixed(1)} = ₪${(w.hourlyGap * w.hoursWorked).floor()}',
                Colors.orangeAccent,
              ),
              const SizedBox(height: 8),
              _breakdownRow(
                'השלמה סופית',
                '₪${w.baseSupplement.floor()} + ₪${(w.hourlyGap * w.hoursWorked).floor()} = ₪${w.supplement.floor()}',
                gold,
                bold: true,
              ),
            ] else ...[
              _breakdownRow(
                'השלמה סופית',
                '₪${w.supplement.floor()} (ללא תוספת מינימום)',
                gold,
                bold: true,
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }
  // פונקציית עזר חדשה להסבר חישוב טיפ לשעה
  void _showHourlyRateCalculation(BuildContext context, ShiftResult shift) {
    final gold = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: gold.withOpacity(0.3), width: 1),
        ),
        title: Column(
          children: [
            Icon(Icons.auto_graph_outlined, color: gold, size: 32),
            const SizedBox(height: 12),
            Text(
              'חישוב טיפ שעתי',
              style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // תצוגת קו שבר
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // השבר: מונה ומכנה
                Column(
                  children: [
                    Text(
                      '₪${shift.totalAmount.floor()}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      height: 2,
                      width: 80,
                      color: gold.withOpacity(0.6),
                    ),
                    Text(
                      '${shift.totalHours.toStringAsFixed(2)} שעות',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                Text('=', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                // תוצאה
                Column(
                  children: [
                    Text(
                      '₪${shift.hourlyRate.toStringAsFixed(2)}',
                      style: TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'לשעה',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'זהו הערך השעתי שמתחלק בין כלל העובדים לפי שעות העבודה שלהם.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('הבנתי, תודה', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _breakdownRow(String label, String value, Color valueColor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍸 מפצל טיפים'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'ניהול עובדים',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkersScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewShiftScreen()),
          );
          _loadShifts();
        },
        backgroundColor: gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('משמרת חדשה',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _shifts.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadShifts,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _shifts.length,
                    itemBuilder: (_, i) => _shiftCard(_shifts[i]),
                  ),
                ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nightlife, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('אין משמרות עדיין',
                style: TextStyle(color: Colors.white54, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('לחץ + כדי להוסיף משמרת',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      );

  Widget _headerStat(String label, String value) {
      return Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  // ── Shift card ────────────────────────────────────────────────────────────

  Widget _shiftCard(ShiftResult shift) {
    final gold = Theme.of(context).colorScheme.primary;

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // כותרת המשמרת - הפוכה (טיפים מימין, שעות משמאל)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // סה"כ טיפים - ימין
              _headerStat('סה"כ טיפים', '₪${shift.totalAmount.floor()}'),

              // טיפ לשעה - מרכז לחיץ
              GestureDetector(
                onTap: () => _showHourlyRateCalculation(context, shift),
                child: Column(
                  children: [
                    const Text('טיפ לשעה', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text(
                      '₪${shift.hourlyRate.floor()}', // ללא נקודה עשרונית
                      style: TextStyle(
                        color: gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),

              // סה"כ שעות - שמאל
              _headerStat('שעות', shift.totalHours.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),

          // טבלה הפוכה (שם בימין) עם שורת סיכום
          _workersTable(shift.workers),
          
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
              onPressed: () => _confirmDelete(shift.id),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── Stat chip ─────────────────────────────────────────────────────────────

  Widget _statChip(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
      );

  // ── Workers table ─────────────────────────────────────────────────────────

  Widget _workersTable(List<WorkerResult> workers) {
    double totalHours = workers.fold(0, (sum, w) => sum + w.hoursWorked);
    double totalTips = workers.fold(0, (sum, w) => sum + w.tipAmount);
    double totalSupp = workers.fold(0, (sum, w) => sum + w.supplement);

    // עטיפה ב-Directionality מבטיחה שהעמודה הראשונה (0) תהיה בימין
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.2), // שם - הכי ימני
          1: FlexColumnWidth(1.2), //  כניסה
          2: FlexColumnWidth(1.2), // יציאה
          3: FlexColumnWidth(1.0), // שעות
          4: FlexColumnWidth(1.8), // טיפים
          5: FlexColumnWidth(1.8), // השלמה
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // כותרות
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            children: ['שם', 'כניסה', 'יציאה', 'שעות', 'טיפים', 'השלמה']
                .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(h,
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                          textAlign: TextAlign.center),
                    ))
                .toList(),
          ),
          
          // שורות עובדים
          ...workers.map((w) => TableRow(
                children: [
                  _cell(w.name, bold: true),             // נכנס לעמודה 0 (ימין)
                  _cell(w.startTime),                     // נכנס לעמודה 1
                  _cell(w.endTime),                       // נכנס לעמודה 2
                  _cell(w.hoursWorked.toStringAsFixed(1)),  // נכנס לעמודה 3
                  _tipCell(w),                            // נכנס לעמודה 4
                  _supplementCell(w),                     // נכנס לעמודה 5   
                ],
              )),

          // שורת סיכום
          TableRow(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              border: const Border(top: BorderSide(color: Colors.white24, width: 1)),
            ),
            children: [
              _cell('סך הכל', bold: true, color: Colors.white),
              _cell(''),
              _cell(''),
              _cell(totalHours.toStringAsFixed(1), bold: true, color: Colors.white),
              _cell('₪${totalTips.floor()}', bold: true, color: Theme.of(context).colorScheme.primary),
              _cell('₪${totalSupp.floor()}', bold: true, color: Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }
  // ── Supplement cell — tappable ────────────────────────────────────────────

  Widget _supplementCell(WorkerResult w) {
    final bool hasGap = w.hourlyGap > 0;
    return GestureDetector(
      onTap: () => _showSupplementBreakdown(context, w),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₪${w.supplement.floor()}', // עיגול למטה
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hasGap ? Colors.orangeAccent : Colors.white70,
                fontSize: 13,
                fontWeight: hasGap ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.info_outline,
                size: 11,
                color: hasGap ? Colors.orangeAccent : Colors.white24),
          ],
        ),
      ),
    );
  }

// ── Tip cell — tappable ───────────────────────────────────────────────────

  Widget _tipCell(WorkerResult w) {
    final gold = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => _showSupplementBreakdown(context, w),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₪${w.tipAmount.floor()}', // עיגול למטה
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gold,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.info_outline, size: 11, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // ── Regular cell ──────────────────────────────────────────────────────────

  Widget _cell(String text, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color ?? Colors.white70,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      );

  // ── Delete confirmation ───────────────────────────────────────────────────

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('מחיקת משמרת'),
        content: const Text('האם למחוק את המשמרת?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); _deleteShift(id); },
            child: const Text('מחק', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
