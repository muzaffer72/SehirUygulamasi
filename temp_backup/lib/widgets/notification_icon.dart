import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Bildirim ikonu widget'ı - okunmamış bildirimlerin sayısını gösteren bir badge ile bildirim ikonu
class NotificationIcon extends StatefulWidget {
  final Color? color;
  final double size;
  final VoidCallback onPressed;

  const NotificationIcon({
    Key? key,
    this.color,
    this.size = 24.0,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  /// Okunmamış bildirim sayısını getirir
  Future<void> _fetchUnreadCount() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final count = await NotificationService.getUnreadCount();
      
      setState(() {
        _unreadCount = count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _unreadCount = 0;
        _isLoading = false;
      });
      debugPrint('Okunmamış bildirim sayısı alınamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: widget.color ?? Theme.of(context).iconTheme.color,
            size: widget.size,
          ),
          onPressed: () {
            widget.onPressed();
            // İkona tıklandığında, yeni bildirimleri kontrol et
            _fetchUnreadCount();
          },
        ),
        if (_unreadCount > 0 && !_isLoading)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (_isLoading)
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bildirim ikonu widget'ı - okunmamış bildirimlerin sayısını otomatik olarak yenileyen bir badge ile bildirim ikonu
class AutoRefreshNotificationIcon extends StatefulWidget {
  final Color? color;
  final double size;
  final VoidCallback onPressed;
  final Duration refreshInterval;

  const AutoRefreshNotificationIcon({
    Key? key,
    this.color,
    this.size = 24.0,
    required this.onPressed,
    this.refreshInterval = const Duration(minutes: 1),
  }) : super(key: key);

  @override
  State<AutoRefreshNotificationIcon> createState() => _AutoRefreshNotificationIconState();
}

class _AutoRefreshNotificationIconState extends State<AutoRefreshNotificationIcon> {
  late NotificationIcon _notificationIcon;

  @override
  void initState() {
    super.initState();
    _notificationIcon = NotificationIcon(
      color: widget.color,
      size: widget.size,
      onPressed: widget.onPressed,
    );
    _scheduleRefresh();
  }

  /// Periyodik olarak bildirimleri yenileme
  void _scheduleRefresh() {
    Future.delayed(widget.refreshInterval, () {
      if (mounted) {
        setState(() {
          _notificationIcon = NotificationIcon(
            color: widget.color,
            size: widget.size,
            onPressed: widget.onPressed,
          );
        });
        _scheduleRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _notificationIcon;
  }
}