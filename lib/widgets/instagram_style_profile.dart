import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InstagramStyleProfile extends ConsumerWidget {
  final String userId;

  const InstagramStyleProfile({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userByIdProvider(userId));
    
    return userAsyncValue.when(
      data: (user) => _buildProfileContent(context, user),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Kullanıcı yüklenirken hata oluştu: $error'),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, user),
                const SizedBox(height: 12),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),
                _buildUserStats(context, user),
                const SizedBox(height: 16),
                _buildUserLevel(context, user),
              ],
            ),
          ),
          _buildTabView(context, user),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Row(
      children: [
        // Profil fotoğrafı
        Hero(
          tag: 'profile-${user.id}',
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage: user.profileImageUrl != null
                ? CachedNetworkImageProvider(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 4),
                  if (user.isVerified)
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Üyelik: ${_formatDate(user.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context, User user) {
    return Row(
      children: [
        _buildStatItem(context, user.postCount.toString(), 'Paylaşım'),
        _buildStatItem(context, user.commentCount.toString(), 'Yorum'),
        _buildStatItem(context, user.points.toString(), 'Puan'),
      ],
    );
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserLevel(BuildContext context, User user) {
    // Seviye çubuğu
    final progressValue = _calculateLevelProgress(user);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: _getLevelColor(user.level),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              user.getLevelName(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getLevelColor(user.level),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(user.level)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          _getLevelProgressText(user),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildTabView(BuildContext context, User user) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Paylaşımlar'),
              Tab(text: 'Yorumlar'),
            ],
          ),
          SizedBox(
            height: 300, // Sabit yükseklik
            child: TabBarView(
              children: [
                // Paylaşımlar sekmesi
                Center(
                  child: Text('Henüz paylaşım yok'),
                ),
                // Yorumlar sekmesi
                Center(
                  child: Text('Henüz yorum yok'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Color _getLevelColor(UserLevel level) {
    switch (level) {
      case UserLevel.newUser:
        return Colors.green;
      case UserLevel.contributor:
        return Colors.blue;
      case UserLevel.active:
        return Colors.purple;
      case UserLevel.expert:
        return Colors.orange;
      case UserLevel.master:
        return Colors.red;
    }
  }
  
  double _calculateLevelProgress(User user) {
    switch (user.level) {
      case UserLevel.newUser:
        return user.points / 100;
      case UserLevel.contributor:
        return (user.points - 101) / 399;
      case UserLevel.active:
        return (user.points - 501) / 499;
      case UserLevel.expert:
        return (user.points - 1001) / 999;
      case UserLevel.master:
        // Master seviyesinde ilerlemeyi göstermeyin
        return 1.0;
    }
  }
  
  String _getLevelProgressText(User user) {
    switch (user.level) {
      case UserLevel.newUser:
        final pointsLeft = 101 - user.points;
        return 'Şehrini Seven seviyesine $pointsLeft puan kaldı';
      case UserLevel.contributor:
        final pointsLeft = 501 - user.points;
        return 'Şehir Sevdalısı seviyesine $pointsLeft puan kaldı';
      case UserLevel.active:
        final pointsLeft = 1001 - user.points;
        return 'Şehir Aşığı seviyesine $pointsLeft puan kaldı';
      case UserLevel.expert:
        final pointsLeft = 2000 - user.points;
        return 'Şehir Uzmanı seviyesine $pointsLeft puan kaldı';
      case UserLevel.master:
        return 'En yüksek seviyedesiniz';
    }
  }
}