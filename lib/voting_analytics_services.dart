import 'package:cloud_firestore/cloud_firestore.dart';

class VotingAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define the exact pilot baseline configurations established for the application
  static const int totalPilotVoters = 500;

  /// Calculates the total votes cast and turnout percentage across ALL regions combined
  Future<Map<String, dynamic>> calculateGrandTotalTurnout() async {
    try {
      // Direct aggregation query counting documents in the 'votes' audit log collection
      final AggregateQuerySnapshot snapshot = await _firestore
          .collection('votes')
          .count()
          .get();

      int grandTotalVotes = snapshot.count ?? 0;

      // Calculate Turnout % using the total pilot baseline formula
      double grandTotalTurnoutPercent = 0.0;
      if (totalPilotVoters > 0) {
        grandTotalTurnoutPercent = (grandTotalVotes / totalPilotVoters) * 100;
      }

      return {
        'grandTotalVotes': grandTotalVotes,
        'grandTotalRegisteredVoters': totalPilotVoters,
        'grandTotalTurnoutPercent': double.parse(
          grandTotalTurnoutPercent.toStringAsFixed(2),
        ),
      };
    } catch (e) {
      print("❌ Error calculating grand total metrics: $e");
      rethrow;
    }
  }

  /// Calculates the total votes cast and turnout percentage for a SPECIFIC region (Constituency)
  /// Pass the sanitized lowercase document ID (e.g., 'dahisar', 'mumbai_central')
  Future<Map<String, dynamic>> calculateRegionalTurnout(
    String constituencyId,
  ) async {
    try {
      // 1. Calculate how many votes have been cast in this region from the audit logs
      final AggregateQuerySnapshot voteSnapshot = await _firestore
          .collection('votes')
          .where('constituencyId', isEqualTo: constituencyId)
          .count()
          .get();

      int regionalVotesCast = voteSnapshot.count ?? 0;

      // 2. Determine total registered voters belonging to this region by querying the voters baseline
      final AggregateQuerySnapshot voterSnapshot = await _firestore
          .collection('voters')
          .where('constituencyId', isEqualTo: constituencyId)
          .count()
          .get();

      int regionalRegisteredVoters = voterSnapshot.count ?? 0;

      // 3. Compute turnout percentage for the target constituency region
      double regionalTurnoutPercent = 0.0;
      if (regionalRegisteredVoters > 0) {
        regionalTurnoutPercent =
            (regionalVotesCast / regionalRegisteredVoters) * 100;
      }

      return {
        'constituencyId': constituencyId,
        'totalVotesCast': regionalVotesCast,
        'totalRegisteredVoters': regionalRegisteredVoters,
        'turnoutPercent': double.parse(
          regionalTurnoutPercent.toStringAsFixed(2),
        ),
      };
    } catch (e) {
      print("❌ Error calculating regional metrics for $constituencyId: $e");
      rethrow;
    }
  }
}
