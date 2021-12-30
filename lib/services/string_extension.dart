//special extension used for strings that allows to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (trim() == '') return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
