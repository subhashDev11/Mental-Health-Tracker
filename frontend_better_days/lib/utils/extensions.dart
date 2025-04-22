extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension DateTimeExtensions on DateTime {
  String toFormattedString() {
    return '$day/$month/$year';
  }
}