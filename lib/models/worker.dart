// ── Worker (input per shift) ─────────────────────────────────────────────────

class Worker {
  String name;
  String startTime;
  String endTime;

  Worker({required this.name, required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() => {
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
      };
}

// ── WorkerRecord (pink table — permanent) ─────────────────────────────────────

class WorkerRecord {
  final int id;
  final String name;
  final double supplement;   // השלמה
  final double minHourly;    // שכר מינימום

  const WorkerRecord({
    required this.id,
    required this.name,
    required this.supplement,
    required this.minHourly,
  });

  factory WorkerRecord.fromJson(Map<String, dynamic> json) => WorkerRecord(
        id: json['id'] as int,
        name: json['name'] as String,
        supplement: (json['supplement'] as num).toDouble(),
        minHourly: (json['min_hourly'] as num).toDouble(),
      );
}

// ── WorkerResult (calculated result) ─────────────────────────────────────────

class WorkerResult {
  final String name;
  final String startTime;
  final String endTime;
  final double hoursWorked;
  final double tipAmount;
  final double tipPerHour;
  final double baseSupplement;
  final double minHourly;
  final double hourlyGap;
  final double supplement;   // final supplement shown in table
  final double total;

  const WorkerResult({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.hoursWorked,
    required this.tipAmount,
    required this.tipPerHour,
    required this.baseSupplement,
    required this.minHourly,
    required this.hourlyGap,
    required this.supplement,
    required this.total,
  });

  factory WorkerResult.fromJson(Map<String, dynamic> json) => WorkerResult(
        name: json['name'] as String,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        hoursWorked: (json['hours_worked'] as num).toDouble(),
        tipAmount: (json['tip_amount'] as num).toDouble(),
        tipPerHour: (json['tip_per_hour'] as num).toDouble(),
        baseSupplement: (json['base_supplement'] as num).toDouble(),
        minHourly: (json['min_hourly'] as num).toDouble(),
        hourlyGap: (json['hourly_gap'] as num).toDouble(),
        supplement: (json['supplement'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
      );
}

// ── ShiftResult (full shift) ──────────────────────────────────────────────────

class ShiftResult {
  final int id;
  final String date;
  final double totalAmount;
  final double totalHours;
  final double hourlyRate;
  final List<WorkerResult> workers;

  const ShiftResult({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.totalHours,
    required this.hourlyRate,
    required this.workers,
  });

  factory ShiftResult.fromJson(Map<String, dynamic> json) => ShiftResult(
        id: json['id'] as int,
        date: json['date'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        totalHours: (json['total_hours'] as num).toDouble(),
        hourlyRate: (json['hourly_rate'] as num).toDouble(),
        workers: (json['workers'] as List)
            .map((w) => WorkerResult.fromJson(w as Map<String, dynamic>))
            .toList(),
      );
}
