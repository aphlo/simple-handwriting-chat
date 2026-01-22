import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_handwriting_chat/services/review_service.dart';

void main() {
  group('ReviewService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('incrementAppLaunchCount', () {
      test('should increment launch count from 0 to 1', () async {
        final service = ReviewService();
        await service.incrementAppLaunchCount();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(ReviewService.appLaunchCountKey), 1);
      });

      test('should increment launch count correctly on multiple calls',
          () async {
        final service = ReviewService();

        await service.incrementAppLaunchCount();
        await service.incrementAppLaunchCount();
        await service.incrementAppLaunchCount();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(ReviewService.appLaunchCountKey), 3);
      });
    });

    group('onClearButtonPressed - Condition 1', () {
      test(
          'should request review on first clear after 3 launches',
          () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 3,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        expect(result, true);
        expect(reviewRequested, true);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(ReviewService.reviewRequestedKey), true);
      });

      test(
          'should NOT request review on first clear with only 2 launches',
          () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 2,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        expect(result, false);
        expect(reviewRequested, false);
      });

      test(
          'should NOT request review on second clear even with 3+ launches',
          () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 5,
          ReviewService.clearButtonCountKey: 1,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        expect(result, false);
        expect(reviewRequested, false);
      });
    });

    group('onClearButtonPressed - Condition 2', () {
      test('should request review on 3rd clear button press', () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 1,
          ReviewService.clearButtonCountKey: 2,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        expect(result, true);
        expect(reviewRequested, true);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(ReviewService.reviewRequestedKey), true);
        expect(prefs.getInt(ReviewService.clearButtonCountKey), 3);
      });

      test('should NOT request review on 2nd clear button press', () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 1,
          ReviewService.clearButtonCountKey: 1,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        expect(result, false);
        expect(reviewRequested, false);
      });
    });

    group('onClearButtonPressed - Review already requested', () {
      test('should NOT request review if already requested (condition 1)',
          () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 10,
          ReviewService.clearButtonCountKey: 0,
          ReviewService.reviewRequestedKey: true,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        expect(result, false);
        expect(reviewRequested, false);
      });

      test('should NOT request review if already requested (condition 2)',
          () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 1,
          ReviewService.clearButtonCountKey: 10,
          ReviewService.reviewRequestedKey: true,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        expect(result, false);
        expect(reviewRequested, false);
      });

      test('should only request review once across multiple triggers',
          () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 3,
        });

        var reviewRequestCount = 0;
        final service = ReviewService(
          onReviewRequested: () => reviewRequestCount++,
        );

        // First clear - should trigger review (condition 1)
        await service.onClearButtonPressed();
        expect(reviewRequestCount, 1);

        // Second clear - should NOT trigger (already requested)
        await service.onClearButtonPressed();
        expect(reviewRequestCount, 1);

        // Third clear - should NOT trigger (already requested)
        await service.onClearButtonPressed();
        expect(reviewRequestCount, 1);
      });
    });

    group('Combined conditions', () {
      test(
          'should trigger on first clear after 3 launches even if clear count would also trigger',
          () async {
        SharedPreferences.setMockInitialValues({
          ReviewService.appLaunchCountKey: 3,
          ReviewService.clearButtonCountKey: 2,
        });

        var reviewRequested = false;
        final service = ReviewService(
          onReviewRequested: () => reviewRequested = true,
        );

        final result = await service.onClearButtonPressed();

        // Both conditions are met, but review should only be requested once
        expect(result, true);
        expect(reviewRequested, true);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(ReviewService.clearButtonCountKey), 3);
      });
    });
  });
}
