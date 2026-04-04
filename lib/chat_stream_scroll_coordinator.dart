import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Keeps the chat list pinned to the bottom while a stream grows, and mirrors
/// typical chat UX: following stops when the user scrolls away and resumes when
/// they return to the bottom.
///
/// [ChatAnimatedList] only scrolls on insert/remove operations; streaming text
/// updates the same list item's height without new operations, so the list
/// would otherwise stay at a stale offset.
class ChatStreamScrollCoordinator {
  ChatStreamScrollCoordinator({
    required this.scrollController,
    this.bottomThreshold = 20,
  });

  final ScrollController scrollController;
  final double bottomThreshold;

  /// When true, layout growth (e.g. new stream tokens) triggers a scroll to end.
  bool stickToBottom = true;

  bool _programmaticScroll = false;
  bool _frameCallbackPending = false;

  bool isNearBottom(ScrollMetrics metrics) {
    if (!metrics.hasContentDimensions) return true;
    return metrics.pixels >= metrics.maxScrollExtent - bottomThreshold;
  }

  /// Touch / trackpad drag updates while the user is viewing older content.
  void onScrollUpdate(ScrollUpdateNotification notification) {
    if (_programmaticScroll) return;
    if (notification.dragDetails == null) return;
    if (!scrollController.hasClients) return;
    if (!isNearBottom(scrollController.position)) {
      stickToBottom = false;
    }
  }

  /// Mouse wheel / trackpad scroll: [PointerScrollEvent] does not set dragDetails.
  void onPointerScroll(PointerSignalEvent event) {
    if (_programmaticScroll) return;
    if (event is! PointerScrollEvent) return;
    if (!scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (_programmaticScroll) return;
      if (!isNearBottom(scrollController.position)) {
        stickToBottom = false;
      }
    });
  }

  /// Re-enable following once the user settles at the bottom.
  void onScrollEnd(ScrollEndNotification notification) {
    if (_programmaticScroll) return;
    if (!scrollController.hasClients) return;
    if (isNearBottom(scrollController.position)) {
      stickToBottom = true;
    }
  }

  /// Call when stream text or message height may have changed.
  void onStreamLayoutMayHaveChanged() {
    if (!stickToBottom) return;
    if (!scrollController.hasClients) return;
    if (_frameCallbackPending) return;
    _frameCallbackPending = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frameCallbackPending = false;
      if (!stickToBottom || !scrollController.hasClients) return;

      _programmaticScroll = true;
      final target = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(target);

      // A second frame catches layout that updates after the first jump
      // (e.g. markdown / stream chunk animations).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (stickToBottom && scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
        _programmaticScroll = false;
      });
    });
  }

  /// Sending a message should follow the conversation again.
  void userSentMessage() {
    stickToBottom = true;
  }
}
