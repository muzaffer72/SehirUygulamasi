class BeforeAfterRecord {
  final int id;
  final int postId;
  final String beforeImageUrl;
  final String afterImageUrl;
  final String? description;
  final int? recordedBy;
  final DateTime recordDate;
  final DateTime createdAt;

  BeforeAfterRecord({
    required this.id,
    required this.postId,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.description,
    this.recordedBy,
    required this.recordDate,
    required this.createdAt,
  });

  factory BeforeAfterRecord.fromJson(Map<String, dynamic> json) {
    return BeforeAfterRecord(
      id: json['id'],
      postId: json['post_id'],
      beforeImageUrl: json['before_image_url'],
      afterImageUrl: json['after_image_url'],
      description: json['description'],
      recordedBy: json['recorded_by'],
      recordDate: DateTime.parse(json['record_date']),
      createdAt: DateTime.parse(json['created_at']),
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