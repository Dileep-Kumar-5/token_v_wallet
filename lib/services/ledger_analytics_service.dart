import '../services/supabase_service.dart';

/// Ledger Analytics Service
///
/// Provides analytics and verification methods for transaction ledger data
class LedgerAnalyticsService {
  final _supabase = SupabaseService.instance.client;

  /// Get transaction verification data with blockchain-style confirmation status
  Future<List<Map<String, dynamic>>> getTransactionVerifications({
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('transaction_ledger')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch transaction verifications: $e');
    }
  }

  /// Detect anomalies in transaction patterns
  Future<List<Map<String, dynamic>>> detectAnomalies() async {
    try {
      // Get all transactions for analysis
      final transactions = await _supabase
          .from('transaction_ledger')
          .select('*')
          .order('created_at', ascending: false)
          .limit(1000);

      final List<Map<String, dynamic>> anomalies = [];

      // Group by user_id for pattern analysis
      final Map<String, List<Map<String, dynamic>>> userTransactions = {};
      for (var tx in transactions) {
        final userId = tx['user_id'] as String;
        userTransactions.putIfAbsent(userId, () => []);
        userTransactions[userId]!.add(tx);
      }

      // Analyze each user's transaction patterns
      for (var entry in userTransactions.entries) {
        final userId = entry.key;
        final txList = entry.value;

        if (txList.isEmpty) continue;

        // Calculate statistics
        final amounts =
            txList.map((tx) => (tx['amount'] as num).toDouble()).toList();
        final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;
        final maxAmount = amounts.reduce((a, b) => a > b ? a : b);

        // Check for unusual patterns
        for (var tx in txList) {
          final amount = (tx['amount'] as num).abs().toDouble();
          final severity = _calculateSeverity(amount, avgAmount, maxAmount);

          if (severity != 'normal') {
            anomalies.add({
              'id': tx['id'],
              'user_id': userId,
              'transaction_id': tx['reference_id'],
              'amount': tx['amount'],
              'type': _getAnomalyType(amount, avgAmount, maxAmount),
              'severity': severity,
              'description': _getAnomalyDescription(amount, avgAmount),
              'timestamp': tx['created_at'],
              'status': tx['transaction_status'],
            });
          }
        }
      }

      return anomalies;
    } catch (e) {
      throw Exception('Failed to detect anomalies: $e');
    }
  }

  /// Get balance reconciliation report
  Future<Map<String, dynamic>> getBalanceReconciliation() async {
    try {
      // Use the existing audit_balance_integrity function
      final response = await _supabase.rpc('audit_balance_integrity').select();

      final results = List<Map<String, dynamic>>.from(response as List);

      // Calculate summary statistics
      int totalUsers = results.length;
      int validBalances = results.where((r) => r['is_valid'] == true).length;
      int discrepancies = totalUsers - validBalances;

      double totalDifference = results.fold(
        0.0,
        (sum, r) => sum + ((r['difference'] as num?)?.toDouble() ?? 0.0),
      );

      return {
        'summary': {
          'total_users': totalUsers,
          'valid_balances': validBalances,
          'discrepancies': discrepancies,
          'total_difference': totalDifference,
          'accuracy_rate':
              totalUsers > 0 ? (validBalances / totalUsers) * 100 : 100.0,
        },
        'details': results,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get balance reconciliation: $e');
    }
  }

  /// Calculate anomaly severity
  String _calculateSeverity(double amount, double avgAmount, double maxAmount) {
    if (amount > avgAmount * 5) {
      return 'critical';
    } else if (amount > avgAmount * 3) {
      return 'high';
    } else if (amount > avgAmount * 2) {
      return 'medium';
    }
    return 'normal';
  }

  /// Get anomaly type description
  String _getAnomalyType(double amount, double avgAmount, double maxAmount) {
    if (amount > avgAmount * 5) {
      return 'Unusually High Transaction';
    } else if (amount > avgAmount * 3) {
      return 'High Volume Transaction';
    } else if (amount > avgAmount * 2) {
      return 'Above Average Transaction';
    }
    return 'Normal Transaction';
  }

  /// Get detailed anomaly description
  String _getAnomalyDescription(double amount, double avgAmount) {
    final ratio = (amount / avgAmount).toStringAsFixed(1);
    return 'Transaction amount is ${ratio}x higher than user average';
  }

  /// Get transaction timeline for visualization
  Future<List<Map<String, dynamic>>> getTransactionTimeline({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('transaction_ledger').select('*');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch transaction timeline: $e');
    }
  }
}
