import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  ReviewService({InAppReview? inAppReview, this.onReviewRequested})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  static const String appLaunchCountKey = 'app_launch_count';
  static const String clearButtonCountKey = 'clear_button_count';
  static const String reviewRequestedKey = 'review_requested';

  static const int requiredLaunchCount = 3;
  static const int requiredClearCount = 3;

  final InAppReview _inAppReview;
  final void Function()? onReviewRequested;

  Future<void> incrementAppLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(appLaunchCountKey) ?? 0;
    await prefs.setInt(appLaunchCountKey, count + 1);
  }

  Future<bool> onClearButtonPressed() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if review has already been requested
    if (prefs.getBool(reviewRequestedKey) == true) {
      return false;
    }

    final launchCount = prefs.getInt(appLaunchCountKey) ?? 0;
    final clearCount = prefs.getInt(clearButtonCountKey) ?? 0;
    final newClearCount = clearCount + 1;

    await prefs.setInt(clearButtonCountKey, newClearCount);

    // Condition 1: After 3 app launches, first clear button press
    final isFirstClearAfterThreeLaunches =
        launchCount >= requiredLaunchCount && clearCount == 0;

    // Condition 2: After 3 clear button presses total
    final isThirdClearPress = newClearCount >= requiredClearCount;

    if (isFirstClearAfterThreeLaunches || isThirdClearPress) {
      await _requestReview();
      await prefs.setBool(reviewRequestedKey, true);
      return true;
    }

    return false;
  }

  Future<void> _requestReview() async {
    onReviewRequested?.call();
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }
}
