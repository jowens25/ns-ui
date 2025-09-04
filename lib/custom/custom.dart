import 'package:flutter/material.dart';

class LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double myGap;

  const LabeledSwitch({
    Key? key,
    required this.myGap,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: myGap,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            width: 32, // control size here
            height: 20,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(value: value, onChanged: onChanged),
            ),
          ),
        ),
      ],
    );
  }
}

class MyChannel extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const MyChannel({
    Key? key,

    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Text("value 1"),
        Text("value 2"),
        Text("value 3"),
      ],
    );
  }
}

class LabeledText extends StatelessWidget {
  final double myGap;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const LabeledText({
    Key? key,
    required this.myGap,
    required this.label,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: myGap,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(isDense: true),
          ),
        ),
      ],
    );
  }
}

class ReadOnlyLabeledText extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double myGap;
  const ReadOnlyLabeledText({
    Key? key,
    required this.myGap,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: myGap,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: TextField(
            readOnly: true,
            controller: controller,

            decoration: InputDecoration(isDense: true),
          ),
        ),
      ],
    );
  }
}

class LabeledDropdown<T> extends StatelessWidget {
  final double myGap;
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const LabeledDropdown({
    Key? key,
    required this.myGap,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: myGap,
            height: 20,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items:
                    items.map<DropdownMenuItem<T>>((T item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(item.toString()),
                      );
                    }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                // Use tight padding
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
