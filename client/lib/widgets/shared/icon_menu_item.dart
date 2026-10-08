import "package:flutter/material.dart";

PopupMenuItem<T> iconMenuItem<T>(T value, IconData icon, String label, {Color? color}) => PopupMenuItem(
  value: value,
  child: ListTile(
    leading: Icon(icon, color: color),
    title: Text(label, style: color == null ? null : TextStyle(color: color)),
  ),
);
