import 'package:intl/intl.dart';

String dateFormatter(double time) {
  final strTime = time.toString();
  final embedded = strTime.replaceAll(".0", "");
  final timestamp = int.tryParse(embedded);
  if (timestamp != null) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    final formattedDate = DateFormat('hh:mm a').format(date);

    return formattedDate;
  } else {
    return "";
  }
}

// String formatDate(DateTime? pickedDate, {bool? isReverseFormat}) {
//   if (pickedDate != null) {
//     return formattedDate;
//   } else if (pickedDate != null && isReverseFormat == true) {
//     final formattedDate = DateFormat('yyyy/MM/dd').format(pickedDate);

//     return formattedDate;
//   } else {
//     return "";
//   }
// }
