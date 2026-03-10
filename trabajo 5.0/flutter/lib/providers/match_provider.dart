import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final DateTime date;
  final String status;
  final int minute;
  final int homeScore;
  final int awayScore;
  final MatchOdds odds;
  final MatchStats? stats;
  
  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.date,
    required this.status,
    required this.minute,
    required this.homeScore,
    required this.awayScore,
    required this.odds,
    this.stats,
  });
  
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['_id'] ?? json['id'] ?? '',
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      league: json['league'] ?? '',
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'scheduled',
      minute: json['minute'] ?? 0,
      homeScore: json['homeScore'] ?? 0,
      awayScore: json['awayScore'] ?? 0,
      odds: MatchOdds.fromJson(json['odds'] ?? {}),
      stats: json['stats'] != null ? MatchStats.fromJson(json['stats']) : null,
    );
  }
  
  bool get isLive => status == 'live';
  bool get isFinished => status == 'finished';
}

class MatchOdds {
  final double homeWin;
  final double draw;
  final double awayWin;
  final double over25;
  final double under25;
  final double bothTeamsScore;
  final double doubleChance1X;
  final double doubleChance12;
  final double doubleChanceX2;
  
  MatchOdds({
    required this.homeWin,
    required this.draw,
    required this.awayWin,
    required this.over25,
    required this.under25,
    required this.bothTeamsScore,
    required this.doubleChance1X,
    required this.doubleChance12,
    required this.doubleChanceX2,
  });
  
  factory MatchOdds.fromJson(Map<String, dynamic> json) {
    return MatchOdds(
      homeWin: (json['homeWin'] ?? 1.0).toDouble(),
      draw: (json['draw'] ?? 1.0).toDouble(),
      awayWin: (json['awayWin'] ?? 1.0).toDouble(),
      over25: (json['over25'] ?? 1.0).toDouble(),
      under25: (json['under25'] ?? 1.0).toDouble(),
      bothTeamsScore: (json['bothTeamsScore'] ?? 1.0).toDouble(),
      doubleChance1X: (json['doubleChance1X'] ?? 1.0).toDouble(),
      doubleChance12: (json['doubleChance12'] ?? 1.0).toDouble(),
      doubleChanceX2: (json['doubleChanceX2'] ?? 1.0).toDouble(),
    );
  }
}

class MatchStats {
  final int possessionHome;
  final int possessionAway;
  final int shotsHome;
  final int shotsAway;
  final int shotsOnTargetHome;
  final int shotsOnTargetAway;
  final int cornersHome;
  final int cornersAway;
  
  MatchStats({
    required this.possessionHome,
    required this.possessionAway,
    required this.shotsHome,
    required this.shotsAway,
    required this.shotsOnTargetHome,
    required this.shotsOnTargetAway,
    required this.cornersHome,
    required this.cornersAway,
  });
  
  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      possessionHome: json['possession']?['home'] ?? 0,
      possessionAway: json['possession']?['away'] ?? 0,
      shotsHome: json['shots']?['home'] ?? 0,
      shotsAway: json['shots']?['away'] ?? 0,
      shotsOnTargetHome: json['shotsOnTarget']?['home'] ?? 0,
      shotsOnTargetAway: json['shotsOnTarget']?['away'] ?? 0,
      cornersHome: json['corners']?['home'] ?? 0,
      cornersAway: json['corners']?['away'] ?? 0,
    );
  }
}

class MatchProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Match> _matches = [];
  List<Match> _liveMatches = [];
  String _currentLeague = 'all';
  String _currentFilter = 'all';
  bool _isLoading = false;
  String? _error;
  
  MatchProvider(this._apiService);
  
  List<Match> get matches => _matches;
  List<Match> get liveMatches => _liveMatches;
  String get currentLeague => _currentLeague;
  String get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final league = _currentLeague == 'all' ? null : _currentLeague;
      final status = _currentFilter == 'all' ? null : _currentFilter;
      
      final data = await _apiService.getMatches(league: league, status: status);
      _matches = data.map((json) => Match.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadLiveMatches() async {
    try {
      final data = await _apiService.getLiveMatches();
      _liveMatches = data.map((json) => Match.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> seedMatchesIfNeeded() async {
    try {
      final data = await _apiService.getMatches();
      if (data.isEmpty) {
        await _apiService.seedMatches();
      }
    } catch (e) {
      // Ignore seed errors
    }
  }
  
  void setLeague(String league) {
    _currentLeague = league;
    notifyListeners();
  }
  
  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }
  
  String formatMatchTime(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    
    if (diff.isNegative && diff.inHours > -2) {
      return 'En vivo';
    }
    
    if (diff.isNegative) {
      return 'Finalizado';
    }
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    
    if (diff.inHours > 0) {
      return 'En ${diff.inHours}h';
    }
    
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
