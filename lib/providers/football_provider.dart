import 'package:flutter/material.dart';
import '../data/models/football_model.dart';
import '../data/services/football_service.dart';

class FootballProvider extends ChangeNotifier {
  List<Football> footballs = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isGenerating = false;

  Future<void> fetchFootballs() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    final result = await FootballService.getFootballs(page);
    List data = result["data"];

    if (data.isEmpty) {
      hasMore = false;
    } else {
      footballs.addAll(
        data.map((e) => Football.fromJson(e)).toList(),
      );
      page++;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> generate(String league, int total) async {
    isGenerating = true;
    notifyListeners();

    try {
      await FootballService.generateFootballs(league, total);

      footballs.clear();
      page = 1;
      hasMore = true;

      await fetchFootballs();
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}