// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../constants/app_colors.dart';
// import '../../../../constants/app_text_styles.dart';
// import '../../../../constants/app_dimensions.dart';

// class CustomDatePicker {
//   /// Shows the custom date picker and returns the selected DateTime
//   static Future<DateTime?> show(
//     BuildContext context, {
//     required DateTime initialDate,
//     required DateTime firstDate,
//     required DateTime lastDate,
//   }) async {
//     return showModalBottomSheet<DateTime>(
//       context: context,
//       isScrollControlled: true,
//       // backgroundColor: Colors.transparent,
//       // barrierColor: Colors.black.withOpacity(0.5),
//       builder:
//           (context) => _DatePickerSheet(
//             initialDate: initialDate,
//             firstDate: firstDate,
//             lastDate: lastDate,
//           ),
//     );
//   }
// }

// class _DatePickerSheet extends StatefulWidget {
//   final DateTime initialDate;
//   final DateTime firstDate;
//   final DateTime lastDate;

//   const _DatePickerSheet({
//     required this.initialDate,
//     required this.firstDate,
//     required this.lastDate,
//   });

//   @override
//   _DatePickerSheetState createState() => _DatePickerSheetState();
// }

// class _DatePickerSheetState extends State<_DatePickerSheet> {
//   late DateTime _selectedDate;
//   final _dateFormat = DateFormat('E, MMM d, yyyy');
//   late List<int> _yearsList;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = widget.initialDate;

//     // Generate years list from firstDate to lastDate
//     _yearsList = [];
//     for (
//       int year = widget.firstDate.year;
//       year <= widget.lastDate.year;
//       year++
//     ) {
//       _yearsList.add(year);
//     }
//     // Reverse the list so most recent years appear first
//     _yearsList = _yearsList.reversed.toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final theme = Theme.of(context);

//     return Container(
//       height: size.height * 0.7,
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//         child: Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             //  color: Colors.white,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Column(
//             children: [
//               _buildHeader(theme),
//               Expanded(child: _buildDatePicker(theme)),
//               _buildFooter(theme),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
//       ),
//       child: Column(
//         children: [
//           // Drag handle
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text('Choose Date of Birth', style: AppTextStyles.heading3),
//           const SizedBox(height: 16),
//           // Selected date summary
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             decoration: BoxDecoration(
//               color: AppColors.primaryDarkBlue.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.calendar_today,
//                   size: 20,
//                   color: AppColors.primaryDarkBlue,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _dateFormat.format(_selectedDate),
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDatePicker(ThemeData theme) {
//     final currentDate = DateTime.now();

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           // Year selection dropdown
//           Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               border: Border.all(color: AppColors.divider),
//               borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<int>(
//                 value: _selectedDate.year,
//                 isExpanded: true,
//                 icon: const Icon(Icons.keyboard_arrow_down),
//                 items:
//                     _yearsList.map((int year) {
//                       return DropdownMenuItem<int>(
//                         value: year,
//                         child: Text(
//                           year.toString(),
//                           style: AppTextStyles.bodyMedium,
//                         ),
//                       );
//                     }).toList(),
//                 onChanged: (int? newYear) {
//                   if (newYear != null) {
//                     setState(() {
//                       // Create a new date with the selected year but same month and day
//                       // Ensure the day is valid for the new month/year
//                       final daysInNewMonth =
//                           DateTime(newYear, _selectedDate.month + 1, 0).day;
//                       final newDay =
//                           _selectedDate.day > daysInNewMonth
//                               ? daysInNewMonth
//                               : _selectedDate.day;

//                       _selectedDate = DateTime(
//                         newYear,
//                         _selectedDate.month,
//                         newDay,
//                       );
//                     });
//                   }
//                 },
//               ),
//             ),
//           ),

//           // Month navigation
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left, color: AppColors.textDark),
//                 onPressed: () {
//                   setState(() {
//                     final newMonth = _selectedDate.month - 1;
//                     final newYear =
//                         newMonth < 1
//                             ? _selectedDate.year - 1
//                             : _selectedDate.year;
//                     final month = newMonth < 1 ? 12 : newMonth;

//                     // Check if the new date would be before firstDate
//                     final newDate = DateTime(newYear, month, 1);
//                     if (newDate.isBefore(widget.firstDate)) return;

//                     // Ensure the day is valid for the new month/year
//                     final daysInNewMonth = DateTime(newYear, month + 1, 0).day;
//                     final newDay =
//                         _selectedDate.day > daysInNewMonth
//                             ? daysInNewMonth
//                             : _selectedDate.day;

//                     _selectedDate = DateTime(newYear, month, newDay);
//                   });
//                 },
//               ),
//               Text(
//                 DateFormat('MMMM').format(_selectedDate),
//                 style: AppTextStyles.bodyLarge.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(
//                   Icons.chevron_right,
//                   color: AppColors.textDark,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     final newMonth = _selectedDate.month + 1;
//                     final newYear =
//                         newMonth > 12
//                             ? _selectedDate.year + 1
//                             : _selectedDate.year;
//                     final month = newMonth > 12 ? 1 : newMonth;

//                     // Check if the new date would be after lastDate
//                     final newDate = DateTime(newYear, month, 1);
//                     if (newDate.isAfter(widget.lastDate)) return;

//                     // Ensure the day is valid for the new month/year
//                     final daysInNewMonth = DateTime(newYear, month + 1, 0).day;
//                     final newDay =
//                         _selectedDate.day > daysInNewMonth
//                             ? daysInNewMonth
//                             : _selectedDate.day;

//                     _selectedDate = DateTime(newYear, month, newDay);
//                   });
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Weekday headers
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               for (final day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
//                 Text(
//                   day,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textMedium,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           // Calendar grid
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7,
//                 childAspectRatio: 1,
//               ),
//               itemCount:
//                   _getDaysInMonth(_selectedDate.year, _selectedDate.month) +
//                   _getFirstDayOfMonth(_selectedDate.year, _selectedDate.month),
//               itemBuilder: (context, index) {
//                 final firstDayOffset = _getFirstDayOfMonth(
//                   _selectedDate.year,
//                   _selectedDate.month,
//                 );

//                 // Empty cells for days before the first day of the month
//                 if (index < firstDayOffset) {
//                   return const SizedBox.shrink();
//                 }

//                 final day = index - firstDayOffset + 1;
//                 final date = DateTime(
//                   _selectedDate.year,
//                   _selectedDate.month,
//                   day,
//                 );

//                 // Check if this date is selectable (between firstDate and lastDate)
//                 final isSelectable =
//                     !date.isBefore(widget.firstDate) &&
//                     !date.isAfter(widget.lastDate);

//                 // Check if this is the selected date
//                 final isSelected =
//                     date.year == _selectedDate.year &&
//                     date.month == _selectedDate.month &&
//                     date.day == _selectedDate.day;

//                 // Check if this is today
//                 final isToday =
//                     date.year == currentDate.year &&
//                     date.month == currentDate.month &&
//                     date.day == currentDate.day;

//                 return GestureDetector(
//                   onTap:
//                       isSelectable
//                           ? () {
//                             setState(() {
//                               _selectedDate = date;
//                             });
//                           }
//                           : null,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color:
//                           isSelected
//                               ? AppColors.primaryDarkBlue
//                               : isToday
//                               ? AppColors.primaryDarkBlue.withOpacity(0.1)
//                               : Colors.transparent,
//                       borderRadius: BorderRadius.circular(12),
//                       border:
//                           isToday && !isSelected
//                               ? Border.all(
//                                 color: AppColors.primaryDarkBlue,
//                                 width: 1,
//                               )
//                               : null,
//                     ),
//                     child: Center(
//                       child: Text(
//                         day.toString(),
//                         style: AppTextStyles.bodyMedium.copyWith(
//                           color:
//                               isSelected
//                                   ? Colors.white
//                                   : isSelectable
//                                   ? AppColors.textDark
//                                   : AppColors.textMedium.withOpacity(0.5),
//                           fontWeight:
//                               isSelected || isToday
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooter(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               'Cancel',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textMedium,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop(_selectedDate);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryDarkBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//               ),
//             ),
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to get the number of days in a month
//   int _getDaysInMonth(int year, int month) {
//     return DateTime(year, month + 1, 0).day;
//   }

//   // Helper method to get the first day of the month (0 = Sunday, 1 = Monday, etc.)
//   int _getFirstDayOfMonth(int year, int month) {
//     return DateTime(year, month, 1).weekday % 7;
//   }
// }
