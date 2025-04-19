import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/comment.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends ConsumerWidget {
  final Comment comment;
  final VoidCallback onLike;
  final Function(String) onReply;
  final bool isReply;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    this.isReply = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 32.0 : 0.0,
        bottom: 8.0,
      ),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and date
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: comment.isAnonymous ? Colors.grey[300] : Colors.blue[100],
                child: Icon(
                  comment.isAnonymous ? Icons.face_retouching_off : Icons.person,
                  size: 16,
                  color: comment.isAnonymous ? Colors.grey[700] : Colors.blue[800],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kullanıcı adı - API'den getirilir
                    if (comment.isAnonymous)
                      const Text(
                        'Gizli Kullanıcı',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    else
                      FutureBuilder<User>(
                        future: ApiService().getUserById(comment.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              'Yükleniyor...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              snapshot.data!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          } else {
                            return Text(
                              'Kullanıcı ${comment.userId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            );
                          }
                        },
                      ),
                      
                    // Yorum zamanı
                    Text(
                      timeago.format(comment.createdAt, locale: 'tr'),
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
          
          // Comment content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(comment.content),
          ),
          
          // Actions
          Row(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_outlined, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likeCount}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (!isReply) // Only show reply button for top-level comments
                InkWell(
                  onTap: () => onReply(comment.id),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(Icons.reply, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Yanıtla',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
