import 'package:flutter/material.dart';

/// Twitter benzeri gönderi oluşturma Floating Action Button
class CreatePostFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CreatePostFAB({
    Key? key,
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4.0,
      tooltip: tooltip ?? 'Yeni Gönderi Oluştur',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        icon ?? Icons.add,
        size: 24,
      ),
    );
  }
}

/// Genişletilmiş gönderi oluşturma FAB
/// Twitter'daki gibi "+" butonu yerine birden fazla seçenek sunan bir FAB
class ExtendedCreatePostFAB extends StatelessWidget {
  final VoidCallback onPhotoPressed;
  final VoidCallback onVideoPressed;
  final VoidCallback onTextPressed;
  final VoidCallback onSurveyPressed;
  
  const ExtendedCreatePostFAB({
    Key? key,
    required this.onPhotoPressed,
    required this.onVideoPressed,
    required this.onTextPressed, 
    required this.onSurveyPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FloatingActionButton.extended(
      onPressed: onTextPressed,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4.0,
      label: Row(
        children: [
          Icon(Icons.edit, size: 16),
          SizedBox(width: 4),
          Text('Paylaş'),
        ],
      ),
      icon: PopupMenuButton<String>(
        offset: Offset(0, -160),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(Icons.arrow_drop_up),
        onSelected: (value) {
          switch (value) {
            case 'photo':
              onPhotoPressed();
              break;
            case 'video':
              onVideoPressed();
              break;
            case 'survey':
              onSurveyPressed();
              break;
            default:
              onTextPressed();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'photo',
            child: Row(
              children: const [
                Icon(Icons.photo, color: Colors.green),
                SizedBox(width: 8),
                Text('Fotoğraf Ekle'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'video',
            child: Row(
              children: const [
                Icon(Icons.videocam, color: Colors.red),
                SizedBox(width: 8),
                Text('Video Ekle'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'survey',
            child: Row(
              children: const [
                Icon(Icons.poll, color: Colors.purple),
                SizedBox(width: 8),
                Text('Anket Oluştur'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}