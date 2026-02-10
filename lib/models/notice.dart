class Notice {
  final String noticeId;
  final String title;
  final String content;
  final String? createTime;

  Notice({
    required this.noticeId,
    required this.title,
    required this.content,
    this.createTime,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      noticeId: json['noticeId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeId': noticeId,
      'title': title,
      'content': content,
      'createTime': createTime,
    };
  }
}
