import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worker.dart';

const String baseUrl = 'http://10.100.102.44:8000';

class ApiService {
  // ── Workers ───────────────────────────────────────────────────────────────

  static Future<List<WorkerRecord>> getWorkers() async {
    final res = await http.get(Uri.parse('$baseUrl/workers'));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((w) => WorkerRecord.fromJson(w as Map<String, dynamic>))
          .toList();
    }
    throw Exception('שגיאה בטעינת עובדים');
  }

  static Future<void> addWorker(String name, double supplement, double minHourly) async {
    await http.post(
      Uri.parse('$baseUrl/workers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'supplement': supplement, 'min_hourly': minHourly}),
    );
  }

  static Future<void> updateWorker(int id, String name, double supplement, double minHourly) async {
    await http.put(
      Uri.parse('$baseUrl/workers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'supplement': supplement, 'min_hourly': minHourly}),
    );
  }

  static Future<void> deleteWorker(int id) async {
    await http.delete(Uri.parse('$baseUrl/workers/$id'));
  }

  // ── Shifts ────────────────────────────────────────────────────────────────

  static Future<ShiftResult> calculateShift(double totalAmount, List<Worker> workers) async {
    final res = await http.post(
      Uri.parse('$baseUrl/calculate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'total_amount': totalAmount,
        'workers': workers.map((w) => w.toJson()).toList(),
      }),
    );
    if (res.statusCode == 200) {
      return ShiftResult.fromJson(jsonDecode(res.body));
    }
    throw Exception('שגיאה בחישוב המשמרת');
  }

  static Future<List<ShiftResult>> getShifts() async {
    final res = await http.get(Uri.parse('$baseUrl/shifts'));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((s) => ShiftResult.fromJson(s))
          .toList();
    }
    throw Exception('שגיאה בטעינת היסטוריה');
  }

  static Future<void> deleteShift(int id) async {
    await http.delete(Uri.parse('$baseUrl/shifts/$id'));
  }
}
