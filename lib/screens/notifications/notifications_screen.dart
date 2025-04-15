import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final notifications = await _apiService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirim işaretlenemedi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Bildirimler yükleniyor...');
    }

    if (_hasError) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Bir hata oluştu',
        message: _errorMessage,
        buttonText: 'Tekrar Dene',
        onButtonPressed: _loadNotifications,
      );
    }

    if (_notifications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_none,
        title: 'Bildirim Yok',
        message: 'Şu anda hiç bildiriminiz bulunmuyor.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final formattedDate = dateFormat.format(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead 
                              ? FontWeight.normal 
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _getNotificationTypeText(notification.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getNotificationTypeColor(notification.type),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'post_update':
        return Icons.update;
      case 'comment':
        return Icons.comment;
      case 'like':
        return Icons.thumb_up;
      case 'system':
        return Icons.info;
      case 'survey':
        return Icons.poll;
      case 'award':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeText(String type) {
    switch (type) {
      case 'post_update':
        return 'Gönderi Güncellemesi';
      case 'comment':
        return 'Yorum';
      case 'like':
        return 'Beğeni';
      case 'system':
        return 'Sistem';
      case 'survey':
        return 'Anket';
      case 'award':
        return 'Ödül';
      default:
        return 'Bildirim';
    }
  }

  Color _getNotificationTypeColor(String type) {
    switch (type) {
      case 'post_update':
        return Colors.blue;
      case 'comment':
        return Colors.purple;
      case 'like':
        return Colors.red;
      case 'system':
        return Colors.teal;
      case 'survey':
        return Colors.orange;
      case 'award':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // İlgili bildirime göre navigasyon işlemleri
    if (notification.data != null) {
      switch (notification.type) {
        case 'post_update':
          if (notification.data!.containsKey('post_id')) {
            final postId = notification.data!['post_id'];
            Navigator.pushNamed(
              context, 
              '/post_detail',
              arguments: {'postId': postId},
            );
          }
          break;
        case 'comment':
          if (notification.data!.containsKey('post_id')) {
            final postId = notification.data!['post_id'];
            Navigator.pushNamed(
              context, 
              '/post_detail',
              arguments: {'postId': postId, 'showComments': true},
            );
          }
          break;
        case 'survey':
          if (notification.data!.containsKey('survey_id')) {
            final surveyId = notification.data!['survey_id'];
            Navigator.pushNamed(
              context, 
              '/survey',
              arguments: {'surveyId': surveyId},
            );
          }
          break;
        // Diğer bildirim türleri için ek durumlar
      }
    }
  }
}