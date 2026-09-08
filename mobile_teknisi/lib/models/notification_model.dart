class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String time;
  final bool isUnread;
  final String? type;
  final String? boldText;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    this.isUnread = false,
    this.type,
    this.boldText,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? json['message'] ?? '',
      time: json['time'] ?? '',
      isUnread: json['is_unread'] == true ||
          json['is_read'] == false ||
          json['is_read'] == 0 ||
          json['read_at'] == null,
      type: json['type'],
      boldText: json['bold_text'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'time': time,
      'is_unread': isUnread,
      'type': type,
      'bold_text': boldText,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
