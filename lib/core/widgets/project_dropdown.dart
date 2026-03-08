import 'package:flutter/material.dart';

class ProjectDropdown extends StatefulWidget {
  final List<String> items;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final String value;
  const ProjectDropdown(
      {super.key,
      required this.items,
      required this.onChanged,
      required this.hint, required this.value});

  @override
  State<ProjectDropdown> createState() => _ProjectDropdownState();
}

class _ProjectDropdownState extends State<ProjectDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton(
        value: widget.value,
          borderRadius: BorderRadius.circular(10),
          hint: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(widget.hint),
          ),
          items: widget.items.map((item) {
            return DropdownMenuItem(child: Text(item), value: item);
          }).toList(),
          onChanged: widget.onChanged),
    );
  }
}
