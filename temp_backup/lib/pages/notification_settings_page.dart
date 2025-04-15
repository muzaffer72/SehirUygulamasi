import 'package:flutter/material.dart';
import '../services/firebase_notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;
  Map<String, bool> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Bildirim ayarlarını yükler
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final settings = await FirebaseNotificationService.getNotificationSettings();
    
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  /// Bildirim ayarını değiştirir
  Future<void> _toggleSetting(String key, bool value) async {
    setState(() {
      _settings[key] = value;
    });
    
    if (key == 'all_notifications') {
      await FirebaseNotificationService.setNotificationsEnabled(value);
    } else {
      await FirebaseNotificationService.setNotificationTypeEnabled(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ana bildirim düğmesi
                    SwitchListTile(
                      title: const Text(
                        'Tüm Bildirimleri Aç/Kapat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: const Text(
                        'Bu ayar kapalıyken hiçbir bildirim almayacaksınız',
                      ),
                      value: _settings['all_notifications'] ?? true,
                      onChanged: (value) => _toggleSetting('all_notifications', value),
                      secondary: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.notifications,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    const Divider(thickness: 1),
                    
                    // Diğer bildirim düğmeleri
                    if (_settings['all_notifications'] == true) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          'Etkileşim Bildirimleri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      
                      _buildNotificationSwitch(
                        'likes',
                        'Beğeni Bildirimleri',
                        'Birileri gönderinizi beğendiğinde bildirim alın',
                        Icons.thumb_up,
                      ),
                      
                      _buildNotificationSwitch(
                        'comments',
                        'Yorum Bildirimleri',
                        'Gönderinize yorum yapıldığında bildirim alın',
                        Icons.comment,
                      ),
                      
                      _buildNotificationSwitch(
                        'new_replies',
                        'Yanıt Bildirimleri',
                        'Yorumunuza yanıt verildiğinde bildirim alın',
                        Icons.reply,
                      ),
                      
                      const Divider(thickness: 1),
                      
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          'Sistem Bildirimleri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      
                      _buildNotificationSwitch(
                        'status_updates',
                        'Durum Güncellemeleri',
                        'Şikayetinizin durumu değiştiğinde bildirim alın',
                        Icons.update,
                      ),
                      
                      _buildNotificationSwitch(
                        'announcements',
                        'Duyurular',
                        'Önemli platform duyurularını alın',
                        Icons.campaign,
                      ),
                      
                      const Divider(thickness: 1),
                      
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          'Konum Tabanlı Bildirimler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      
                      _buildNotificationSwitch(
                        'local_notifications',
                        'Yerel Bildirimleri',
                        'Yaşadığınız şehir veya ilçe ile ilgili bildirimleri alın',
                        Icons.location_on,
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    if (_settings['all_notifications'] != true)
                      const Card(
                        color: Color(0xFFFFF3E0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Tüm bildirimler kapalı olduğu için diğer bildirim ayarları gizlenmiştir.',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Firebase token bağlantısı butonu
                    if (_settings['all_notifications'] == true)
                      Center(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.sync),
                          label: const Text('Bildirim Bağlantısını Yenile'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bildirim bağlantısı güncelleniyor...'),
                              ),
                            );
                            // Firebase FCM token'ı yenile
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Bildirim türü için switch widget'ı oluşturur
  Widget _buildNotificationSwitch(
    String key,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: _settings[key] ?? true,
      onChanged: (value) => _toggleSetting(key, value),
      secondary: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}