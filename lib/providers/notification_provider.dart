import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  final NotificationService _notificationService;

  int _unreadCount = 0;
  int _requestId = 0;
  bool _isRefreshing = false;

  int get unreadCount => _unreadCount;
  bool get hasUnreadNotifications => _unreadCount > 0;
  bool get isRefreshing => _isRefreshing;

  Future<void> refreshUnreadCount() async {
    final int requestId = ++_requestId;

    if (!_isRefreshing) {
      _isRefreshing = true;
      notifyListeners();
    }

    try {
      int page = 1;
      int lastPage = 1;
      int unreadCount = 0;

      do {
        final response = await _notificationService.fetchNotifications(
          page: page,
        );

        unreadCount += response.notifications
            .where((notification) => !notification.isRead)
            .length;

        lastPage = response.lastPage;
        page += 1;
      } while (page <= lastPage);

      if (requestId != _requestId) {
        return;
      }

      final bool countChanged = _unreadCount != unreadCount;

      _unreadCount = unreadCount;
      _isRefreshing = false;

      if (countChanged) {
        notifyListeners();
      } else {
        notifyListeners();
      }
    } catch (_) {
      if (requestId != _requestId) {
        return;
      }

      _isRefreshing = false;
      notifyListeners();
    }
  }

  void clearUnreadCount() {
    if (_unreadCount == 0) {
      return;
    }

    _unreadCount = 0;
    notifyListeners();
  }
}
