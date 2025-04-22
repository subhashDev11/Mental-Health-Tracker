import 'package:intl/intl.dart';

class Journal {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime? createdAt;
  final Map<String,dynamic>? createdBy;

  Journal({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.createdBy,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      createdBy: json['created_by'],
      id: json['id'] ?? "",
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] ?? ""),
    );
  }

  String get formattedDate {
    if(createdAt==null) return "";
    return DateFormat("dd MMM yyyy hh:mm a").format(createdAt!);
  }
}