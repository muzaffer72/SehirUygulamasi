class BeforeAfterRecord {
  final String id;
  final String postId;
  final String beforeImageUrl;
  final String afterImageUrl;
  final String? description;
  final String recordedBy;
  final DateTime recordDate;
  final DateTime createdAt;
  
  BeforeAfterRecord({
    required this.id,
    required this.postId,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.description,
    required this.recordedBy,
    required this.recordDate,
    required this.createdAt,
  });
  
  factory BeforeAfterRecord.fromJson(Map<String, dynamic> json) {
    return BeforeAfterRecord(
      id: json['id'].toString(),
      postId: json['post_id'].toString(),
      beforeImageUrl: json['before_image_url'],
      afterImageUrl: json['after_image_url'],
      description: json['description'],
      recordedBy: json['recorded_by'].toString(),
      recordDate: json['record_date'] != null
          ? DateTime.parse(json['record_date'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'before_image_url': beforeImageUrl,
      'after_image_url': afterImageUrl,
      'description': description,
      'recorded_by': recordedBy,
      'record_date': recordDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}