import 'package:flutter/material.dart';
import 'package:sikayet_var/models/user.dart';

class UserBadgeWidget extends StatelessWidget {
  final UserBadge badge;
  final bool isSmall;
  final bool showName;
  final User user;
  
  const UserBadgeWidget({
    super.key,
    required this.badge,
    required this.user,
    this.isSmall = false,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    final badgeInfo = user.getBadgeInfo(badge);
    final badgeName = badgeInfo['name'] as String;
    final badgeDescription = badgeInfo['description'] as String;
    final badgeIcon = badgeInfo['icon'] as String;
    final badgeColor = Color(badgeInfo['color'] as int);
    
    final badgeSize = isSmall ? 40.0 : 60.0;
    final iconSize = isSmall ? 22.0 : 32.0;
    
    return Tooltip(
      message: badgeDescription,
      preferBelow: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeColor.withOpacity(0.2),
              border: Border.all(
                color: badgeColor,
                width: 2.0,
              ),
            ),
            child: Icon(
              _getIconData(badgeIcon),
              color: badgeColor,
              size: iconSize,
            ),
          ),
          if (showName) ...[
            const SizedBox(height: 4),
            Text(
              badgeName,
              style: TextStyle(
                fontSize: isSmall ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'visibility':
        return Icons.visibility;
      case 'bug_report':
        return Icons.bug_report;
      case 'people':
        return Icons.people;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'forum':
        return Icons.forum;
      case 'eco':
        return Icons.eco;
      case 'construction':
        return Icons.construction;
      case 'directions_bus':
        return Icons.directions_bus;
      default:
        return Icons.star;
    }
  }
}

class UserBadgesRow extends StatelessWidget {
  final User user;
  final bool isSmall;
  final bool showAllBadges;
  final bool showNames;
  final MainAxisAlignment alignment;
  
  const UserBadgesRow({
    super.key, 
    required this.user,
    this.isSmall = false,
    this.showAllBadges = false,
    this.showNames = true,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (user.badges.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final badges = showAllBadges ? user.badges : user.badges.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showNames && badges.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Rozetler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
        Row(
          mainAxisAlignment: alignment,
          children: [
            for (int i = 0; i < badges.length; i++) ...[
              UserBadgeWidget(
                badge: badges[i],
                user: user,
                isSmall: isSmall,
                showName: showNames,
              ),
              if (i < badges.length - 1)
                SizedBox(width: isSmall ? 8 : 16),
            ],
            if (!showAllBadges && user.badges.length > 3) ...[
              SizedBox(width: isSmall ? 8 : 16),
              _buildMoreBadgesIndicator(context),
            ],
          ],
        ),
      ],
    );
  }
  
  Widget _buildMoreBadgesIndicator(BuildContext context) {
    final count = user.badges.length - 3;
    final size = isSmall ? 40.0 : 60.0;
    
    return Tooltip(
      message: '$count daha fazla rozet',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2.0,
          ),
        ),
        child: Center(
          child: Text(
            '+$count',
            style: TextStyle(
              fontSize: isSmall ? 12 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}