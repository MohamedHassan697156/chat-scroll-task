import 'package:chatscrollchallenge/chat_stream_scroll_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isNearBottom within threshold', () {
    final scrollController = ScrollController();
    final coordinator = ChatStreamScrollCoordinator(
      scrollController: scrollController,
      bottomThreshold: 20,
    );
    final near = FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 1000,
      pixels: 980,
      viewportDimension: 600,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 1,
    );
    final far = FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 1000,
      pixels: 0,
      viewportDimension: 600,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 1,
    );
    expect(coordinator.isNearBottom(near), isTrue);
    expect(coordinator.isNearBottom(far), isFalse);
    scrollController.dispose();
  });

  test('userSentMessage restores stickToBottom', () {
    final scrollController = ScrollController();
    final coordinator = ChatStreamScrollCoordinator(
      scrollController: scrollController,
    );
    coordinator.stickToBottom = false;
    coordinator.userSentMessage();
    expect(coordinator.stickToBottom, isTrue);
    scrollController.dispose();
  });
}
