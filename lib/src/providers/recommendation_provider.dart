import 'package:flutter/material.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/services/recommendation_service.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _recommendationService;

  RecommendationProvider({RecommendationService? recommendationService})
      : _recommendationService =
            recommendationService ?? RecommendationService();

  List<Book> get recommendations => _recommendationService.recommendations;
  bool get isLoading => _recommendationService.isLoading;
  String? get errorMessage => _recommendationService.errorMessage;

  /// Fetch book recommendations based on cart items
  Future<List<Book>> getRecommendations({List<int>? bookIds}) async {
    return await _recommendationService.getRecommendations(bookIds: bookIds);
  }
}
