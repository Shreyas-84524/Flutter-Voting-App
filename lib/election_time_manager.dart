import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionTimeManager extends ChangeNotifier with WidgetsBindingObserver {
  static final ElectionTimeManager instance = ElectionTimeManager._internal();

  ElectionTimeManager._internal() {
    WidgetsBinding.instance.addObserver(this);
    _fetchEndTimeAndStartTimer();
  }

  DateTime? _endTime;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isClosed = false;
  bool _isLoading = true;

  DateTime? get endTime => _endTime;
  Duration get remaining => _remaining;
  bool get isClosed => _isClosed;
  bool get isLoading => _isLoading;

  String get formattedRemaining {
    if (_isClosed || _remaining.isNegative) return "00:00:00";
    // Using inHours directly lets us show hours > 24 if the deadline is far away
    String hours = _remaining.inHours.toString().padLeft(2, '0');
    String minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> _fetchEndTimeAndStartTimer() async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await FirebaseFirestore.instance
          .collection('system_config')
          .doc('election_state')
          .get();

      if (doc.exists && doc.data() != null && doc.data()!['endTime'] != null) {
        final timestamp = doc.data()!['endTime'] as Timestamp;
        _endTime = timestamp.toDate();
      } else {
        // Fallback: 11 June 2026 12:00 AM (midnight)
        _endTime = DateTime(2026, 6, 11, 0, 0, 0);
      }
    } catch (e) {
      debugPrint("Error fetching election end time: $e");
      // Fallback
      _endTime = DateTime(2026, 6, 11, 0, 0, 0);
    } finally {
      _isLoading = false;
      _updateTime();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (_endTime == null) return;
    final now = DateTime.now();
    _remaining = _endTime!.difference(now);

    _isClosed = _remaining.isNegative || _remaining == Duration.zero;

    if (_isClosed && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }

    notifyListeners();
  }

  // Allow manual refreshing if needed
  Future<void> refresh() async {
    await _fetchEndTimeAndStartTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, refreshing election state...");
      _fetchEndTimeAndStartTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
