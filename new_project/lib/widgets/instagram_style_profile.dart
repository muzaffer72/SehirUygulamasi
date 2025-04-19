import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/providers/user_provider.dart';
import 'package:belediye_iletisim_merkezi/widgets/user_badge_widget.dart';
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
                const SizedBox(height: 16),
                _buildUserBadges(context, user),
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
  
  // Kullanıcı rozetleri
  Widget _buildUserBadges(BuildContext context, User user) {
    // Kullanıcının rozeti yoksa ve belirli bir seviyedeyse birkaç rozet ekleyelim
    if (user.badges.isEmpty && user.level != UserLevel.newUser) {
      // Test verileri (gerçek uygulamada API'den gelecek)
      List<UserBadge> badges = [];
      
      // Kullanıcının seviyesine göre rozet ekleyelim
      if (user.level == UserLevel.contributor) {
        badges = [UserBadge.toplumdanBiri];
      } else if (user.level == UserLevel.active) {
        badges = [UserBadge.toplumdanBiri, UserBadge.sorunAvcisi];
      } else if (user.level == UserLevel.expert) {
        badges = [UserBadge.toplumdanBiri, UserBadge.sorunAvcisi, UserBadge.mahalleBekci];
      } else if (user.level == UserLevel.master) {
        badges = [
          UserBadge.toplumdanBiri, 
          UserBadge.sorunAvcisi,
          UserBadge.mahalleBekci,
          UserBadge.halkTemsilcisi
        ];
      }
      
      // Kullanıcı nesnesini rozet bilgileriyle güncelleyelim
      final updatedUser = user.copyWith(badges: badges);
      return _renderBadges(context, updatedUser);
    } else if (user.badges.isNotEmpty) {
      return _renderBadges(context, user);
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_outlined, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Henüz rozetiniz yok',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paylaşım, yorum yaparak veya sorunların çözümüne katkıda bulunarak rozet kazanabilirsiniz.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
  
  Widget _renderBadges(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rozetler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            if (user.badges.length > 3)
              TextButton(
                onPressed: () {
                  // Tüm rozetleri göster
                  showDialog(
                    context: context,
                    builder: (context) => _buildAllBadgesDialog(context, user),
                  );
                },
                child: const Text('Tümünü Gör'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        UserBadgesRow(
          user: user,
          showAllBadges: false,
          showNames: true,
          isSmall: false,
        ),
      ],
    );
  }
  
  Widget _buildAllBadgesDialog(BuildContext context, User user) {
    return AlertDialog(
      title: const Text('Tüm Rozetler'),
      content: SizedBox(
        width: double.maxFinite,
        child: Wrap(
          spacing: 12,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: user.badges.map((badge) {
            final badgeInfo = user.getBadgeInfo(badge);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserBadgeWidget(
                  badge: badge,
                  user: user,
                  isSmall: false,
                  showName: false,
                ),
                const SizedBox(height: 4),
                Text(
                  badgeInfo['name'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 120,
                  child: Text(
                    badgeInfo['description'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}