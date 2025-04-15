import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/notification.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/providers/current_user_provider.dart';
import 'package:belediye_iletisim_merkezi/screens/posts/post_detail_screen.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<DatabaseNotification> _notifications = [];
  int _page = 1;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _page = 1;
    });

    try {
      final notifications = await _apiService.getNotifications(
        userId: int.parse(user.id),
        page: _page,
        limit: _limit,
      );

      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _hasMore = notifications.length >= _limit;
      });

      _markAllAsRead();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Bildirimler yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() {
      _isLoadingMore = true;
      _page++;
    });

    try {
      final notifications = await _apiService.getNotifications(
        userId: int.parse(user.id),
        page: _page,
        limit: _limit,
      );

      setState(() {
        _notifications.addAll(notifications);
        _isLoadingMore = false;
        _hasMore = notifications.length >= _limit;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Daha fazla bildirim yüklenirken bir hata oluştu: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      await _apiService.markAllNotificationsAsRead(int.parse(user.id));
    } catch (e) {
      print('Tüm bildirimleri okundu olarak işaretlerken hata: $e');
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Bildirimi okundu olarak işaretlerken hata: $e');
    }
  }

  Future<void> _onNotificationTap(DatabaseNotification notification) async {
    // Bildirimi okundu olarak işaretle
    await _markAsRead(int.parse(notification.id));

    // İlgili sayfaya yönlendir
    if (notification.relatedPostId != null) {
      try {
        final post = await _apiService.getPostById(notification.relatedPostId!);
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Gönderi yüklenirken bir hata oluştu: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyView()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index == _notifications.length) {
                        return _buildLoadingIndicator();
                      }
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Hiç bildiriminiz yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
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
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Yenile'),
            onPressed: _loadNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNotificationItem(DatabaseNotification notification) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? Colors.grey[200]
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          _getNotificationIcon(notification.type),
          color: notification.isRead
              ? Colors.grey[600]
              : Theme.of(context).colorScheme.primary,
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
          Text(notification.content),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMMM yyyy, HH:mm', 'tr').format(notification.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => _onNotificationTap(notification),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'comment':
        return Icons.comment;
      case 'like':
        return Icons.thumb_up;
      case 'mention':
        return Icons.alternate_email;
      case 'system':
        return Icons.info;
      case 'status':
        return Icons.update;
      case 'solution':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }
}