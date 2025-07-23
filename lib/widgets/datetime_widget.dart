import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatetimeWidget extends StatefulWidget {
  const DatetimeWidget({
    super.key,
    required this.dateAndTime,
    this.format = 'yyyy-MM-dd HH:mm',
    this.labelText = 'Date',
    required onDone,
  });
  final String dateAndTime;
  final String labelText;
  final String format;
  final Function? onDone = null;

  @override
  State<DatetimeWidget> createState() => _DatetimeWidgetState();
}

class _DatetimeWidgetState extends State<DatetimeWidget> {
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;
  late String _dateAndTime;
  late TextEditingController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _dateAndTime = widget.dateAndTime;
    _pickedDate = DateTime.parse(_dateAndTime);
    _pickedTime = TimeOfDay.fromDateTime(DateTime.parse(_dateAndTime));
    _controller = TextEditingController(
      text: DateFormat(widget.format).format(_pickedDate!),
    );
  }

  // The _controller is already initialized in initState
  @override
  Widget build(BuildContext context) {
    // TextEditingController _controller = TextEditingController(
    //   text: DateFormat(widget.format).format(_pickedDate!),
    // );
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Date',
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // added line
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _pickedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _pickedDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      _pickedTime!.hour,
                      _pickedTime!.minute,
                    );
                    // _dateAndTime = _pickedDate.toString();
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.schedule),
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _pickedTime!,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null) {
                  setState(() {
                    _pickedTime = pickedTime;
                    _pickedDate = DateTime(
                      _pickedDate!.year,
                      _pickedDate!.month,
                      _pickedDate!.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    // _dateAndTime = _pickedDate.toString();
                  });
                }
              },
            ),
          ],
        ),
      ),
      onSaved: (value) => widget.onDone?.call(_pickedDate.toString()),
    );
  }
}
