import '../model/review.dart';
import '../repository/review_repository.dart';

class ReviewService {
  final ReviewRepository reviewRepository;

  ReviewService(this.reviewRepository);

  Future<List<Review>> getFilteredReviews(int vetId, String explanationType) {
    return reviewRepository.fetchFilteredReviews(vetId, explanationType);
  }
}
