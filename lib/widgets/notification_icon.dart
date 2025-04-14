import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationIcon extends StatefulWidget {
  final Color? color;
  final double size;
  final VoidCallback onTap;

  const NotificationIcon({
    Key? key,
    this.color,
    this.size = 24.0,
    required this.onTap,
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
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final count = await NotificationService.getUnreadNotificationCount();
      setState(() {
        _unreadCount = count;
        _isLoading = false;
      });
    } catch (e) {
      print('Bildirim sayısı alınırken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications,
            color: widget.color,
            size: widget.size,
          ),
          if (_unreadCount > 0)
            Positioned(
              top: -5,
              right: -5,
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
                  _unreadCount > 9 ? '9+' : _unreadCount.toString(),
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
              top: -5,
              right: -5,
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
      ),
    );
  }
}