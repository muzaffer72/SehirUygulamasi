import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/comment.dart';
import 'package:belediye_iletisim_merkezi/utils/date_formatter.dart';
import 'package:belediye_iletisim_merkezi/utils/constants.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final Function()? onLike;
  
  const CommentCard({
    Key? key,
    required this.comment,
    this.onLike,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı avatarı
          CircleAvatar(
            radius: 20,
            backgroundImage: comment.user?.profileImageUrl != null
                ? NetworkImage(comment.user!.profileImageUrl!)
                : null,
            backgroundColor: Colors.grey[200],
            child: comment.user?.profileImageUrl == null
                ? Text(
                    comment.user?.name != null
                        ? comment.user!.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 16),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // Yorum içeriği
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı bilgisi ve tarih
                Row(
                  children: [
                    // Kullanıcı adı
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: comment.user?.name ?? 'İsimsiz Kullanıcı',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (comment.user?.isVerified == true) 
                              const WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            if (comment.isOfficial)
                              const WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.verified_user,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Tarih
                    Text(
                      DateFormatter.formatRelative(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Yorum metni
                Text(
                  comment.content,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Yorum aksiyonları
                Row(
                  children: [
                    // Beğen butonu
                    InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likes}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Yanıtla butonu (şimdilik deaktif)
                    InkWell(
                      onTap: () {
                        // Yanıtlama fonksiyonu
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Yanıtla',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}