import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/notification_model.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/widgets/app_shimmer.dart';
import 'package:belediye_iletisim_merkezi/utils/date_formatter.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  // Bildirimleri yükle
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        final notifications = await _apiService.getNotificationsByUserId(
          authState.user!.id,
        );
        
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bildirimler yüklenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Bildirimleri yenile
  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }
  
  // Bildirimi okundu olarak işaretle
  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    try {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        await _apiService.markNotificationAsRead(
          notification.id,
          authState.user!.id,
        );
        
        setState(() {
          final index = _notifications.indexOf(notification);
          if (index != -1) {
            _notifications[index] = notification.copyWith(isRead: true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bildirim okundu olarak işaretlenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  // Tüm bildirimleri okundu olarak işaretle
  Future<void> _markAllAsRead() async {
    if (_notifications.isEmpty) return;
    
    final unreadExists = _notifications.any((notification) => !notification.isRead);
    if (!unreadExists) return;
    
    try {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        await _apiService.markAllNotificationsAsRead(
          authState.user!.id,
        );
        
        setState(() {
          _notifications = _notifications.map((notification) {
            return notification.copyWith(isRead: true);
          }).toList();
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tüm bildirimler okundu olarak işaretlendi'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bildirimler okundu olarak işaretlenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          if (!_isLoading && _notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tümünü okundu olarak işaretle',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _isLoading
            ? _buildLoadingState()
            : _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(),
      ),
    );
  }
  
  // Yükleme durumu
  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: AppShimmer(
            child: Card(
              child: SizedBox(
                height: 80,
                width: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Boş durum
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Bildiriminiz Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bildirimler geldiğinde burada görünecek',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Bildirim listesi
  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: _notifications.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          elevation: notification.isRead ? 0 : 2,
          color: notification.isRead 
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primary.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(notification.type),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notification.message),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatRelative(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              _markAsRead(notification);
              
              // Bildirimin ilgili sayfasına yönlendir
              if (notification.postId != null) {
                Navigator.pushNamed(
                  context,
                  '/post_detail',
                  arguments: notification.postId,
                );
              } else if (notification.cityId != null) {
                Navigator.pushNamed(
                  context,
                  '/city_profile',
                  arguments: int.parse(notification.cityId!),
                );
              }
            },
          ),
        );
      },
    );
  }
  
  // Bildirim tipine göre renk
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'comment':
        return Colors.blue;
      case 'like':
        return Colors.red;
      case 'mention':
        return Colors.purple;
      case 'system':
        return Colors.green;
      case 'status_update':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  // Bildirim tipine göre ikon
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'comment':
        return Icons.comment;
      case 'like':
        return Icons.favorite;
      case 'mention':
        return Icons.alternate_email;
      case 'system':
        return Icons.info;
      case 'status_update':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }
}