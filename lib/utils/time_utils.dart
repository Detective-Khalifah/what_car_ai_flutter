import 'package:timeago/timeago.dart' as timeago;

/// Converts a timestamp to a human-readable relative time (e.g., "2 days ago")
String getRelativeTime(int time) {
  final now = DateTime.now();
  final timestamp = DateTime.fromMillisecondsSinceEpoch(time);
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays}d ago';
  } else {
    return '${timestamp.year}-${timestamp.month}-${timestamp.day}';
  }
}

String getRelativeTimePkg(DateTime timestamp) {
  return timeago.format(timestamp);
}
