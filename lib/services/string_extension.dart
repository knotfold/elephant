extension StringExtension on String {
  String capitalize() {
    if (trim() == '') return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
