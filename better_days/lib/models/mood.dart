
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Mood {
  final String id;
  final MoodEnum? value;
  final String? note;
  final DateTime? date;

  Mood({
    required this.id,
    required this.value,
    this.note,
    required this.date,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      value: (json['mood'] is int) ? MoodExtension.fromInt(json['mood']) : null,
      note: json['note'],
      date: DateTime.tryParse(json['created_at'] ?? json['create_at']),
    );
  }

  String get formattedDate {
    if(date==null) return "";
    return DateFormat("dd MMM yyyy hh:mm a").format(date!);
    return '${date?.day}/${date?.month}/${date?.year} ${date?.hour}:${date?.minute.toString().padLeft(2, '0')}';
  }
}



enum MoodEnum {
  verySad,
  sad,
  neutral,
  happy,
  veryHappy,
}

extension MoodExtension on MoodEnum {
  int get value => index + 1;

  static MoodEnum fromInt(int value) {
    return MoodEnum.values[(value - 1).clamp(0, MoodEnum.values.length - 1)];
  }

  Color get getMoodColor {
    switch (this) {
      case MoodEnum.verySad:
        return Colors.deepPurple.shade900;
      case MoodEnum.sad:
        return Colors.blueGrey;
      case MoodEnum.neutral:
        return Colors.grey;
      case MoodEnum.happy:
        return Colors.lightGreen;
      case MoodEnum.veryHappy:
        return Colors.amber;
    }
  }

  String get getMoodEmoji {
    switch (value) {
      case 1:
        return '😠';
      case 2:
        return '😞';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😁';
      default:
        return '❓';
    }
  }

  String get moodLabel {
    switch (this) {
      case MoodEnum.verySad:
        return "Very sad";
      case MoodEnum.sad:
        return "Sad";
      case MoodEnum.neutral:
        return "Neutral";
      case MoodEnum.happy:
        return "Happy";
      case MoodEnum.veryHappy:
        return "Very happy";
    }
  }
}