class BeforeAfterRecord {
  final String id;
  final String postId;
  final String beforeImageUrl;
  final String afterImageUrl;
  final String? description;
  final DateTime recordDate;
  final String? adminId;
  
  BeforeAfterRecord({
    required this.id,
    required this.postId,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.description,
    required this.recordDate,
    this.adminId,
  });
  
  factory BeforeAfterRecord.fromJson(Map<String, dynamic> json) {
    return BeforeAfterRecord(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      beforeImageUrl: json['before_image_url'],
      afterImageUrl: json['after_image_url'],
      description: json['description'],
      recordDate: json['record_date'] != null
          ? DateTime.parse(json['record_date'])
          : DateTime.now(),
      adminId: json['admin_id']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'before_image_url': beforeImageUrl,
      'after_image_url': afterImageUrl,
      'description': description,
      'record_date': recordDate.toIso8601String(),
      'admin_id': adminId,
    };
  }
}