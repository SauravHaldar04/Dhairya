import 'package:flutter/material.dart';
import '../../domain/entities/time_slot_entity.dart';


class TimeSlotPicker extends StatefulWidget {
  final TimeSlot? initialTimeSlot;
  final Function(TimeSlot) onTimeSlotSelected;
  final String? labelText;

  const TimeSlotPicker({
    Key? key,
    this.initialTimeSlot,
    required this.onTimeSlotSelected,
    this.labelText,
  }) : super(key: key);

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialTimeSlot != null) {
      final start = widget.initialTimeSlot!.startTime.split(':');
      final end = widget.initialTimeSlot!.endTime.split(':');
      startTime = TimeOfDay(hour: int.parse(start[0]), minute: int.parse(start[1]));
      endTime = TimeOfDay(hour: int.parse(end[0]), minute: int.parse(end[1]));
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? startTime : endTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }

        if (startTime != null && endTime != null) {
          widget.onTimeSlotSelected(
            TimeSlot(
              startTime: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
              endTime: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
              day: '',
            ),
          );
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(
                      color: startTime != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                      width: startTime != null ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(startTime),
                        style: TextStyle(
                          fontSize: 16,
                          color: startTime != null ? Colors.black87 : Colors.grey.shade600,
                          fontWeight: startTime != null ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      Icon(
                        Icons.access_time_rounded,
                        color: startTime != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.arrow_forward, color: Colors.grey),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(
                      color: endTime != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                      width: endTime != null ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(endTime),
                        style: TextStyle(
                          fontSize: 16,
                          color: endTime != null ? Colors.black87 : Colors.grey.shade600,
                          fontWeight: endTime != null ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      Icon(
                        Icons.access_time_rounded,
                        color: endTime != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
