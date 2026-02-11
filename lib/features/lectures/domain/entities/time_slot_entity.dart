class TimeSlot {
  final String day;
  final String startTime;
  final String endTime;

  const TimeSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() => {
    'day': day,
    'start': startTime,
    'end': endTime,
  };

  factory TimeSlot.fromMap(Map<String, dynamic> map) => TimeSlot(
    day: map['day'],
    startTime: map['start'],
    endTime: map['end'],
  );

  @override
  String toString() => '$day $startTime-$endTime';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot &&
        other.day == day &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => day.hashCode ^ startTime.hashCode ^ endTime.hashCode;
}