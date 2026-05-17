import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatting/egp_format.dart';
import '../../../../core/theme/theme_tokens_x.dart';
import '../../domain/attendance.dart';
import '../../domain/payroll_calculation_service.dart';
import '../cubit/employee_detail_cubit.dart';
import '../cubit/employee_detail_state.dart';
import 'attendance_time_picker.dart';

class AttendanceTable extends StatelessWidget {
  const AttendanceTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        final weekDays = PayrollCalculationService.getWeekDays(state.weekStart!);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                context.almazinTokens.surfaceContainer,
              ),
              columns: const [
                DataColumn(label: Text('اليوم')),
                DataColumn(label: Text('التاريخ')),
                DataColumn(label: Text('الحضور')),
                DataColumn(label: Text('الانصراف')),
                DataColumn(label: Text('الساعات')),
                DataColumn(label: Text('الأجر')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('إجراءات')),
              ],
              rows: List.generate(weekDays.length, (i) {
                final day = weekDays[i];
                final attendance = state.attendances.firstWhere(
                  (a) => PayrollCalculationService.isSameDay(a.date, day),
                  orElse: () => Attendance(
                    id: '',
                    employeeId: state.employee!.id,
                    date: day,
                  ),
                );

                return _buildAttendanceRow(
                  context,
                  attendance: attendance,
                  isClosed: state.isWeekClosed,
                  dayIndex: i,
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

const _dayNames = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

String _formatTime(DateTime? dt) {
  if (dt == null) return '--:--';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

void _updateAttendance(BuildContext context, Attendance attendance, {DateTime? checkIn, DateTime? checkOut}) {
  final updated = attendance.copyWith(
    checkIn: checkIn ?? attendance.checkIn,
    checkOut: checkOut ?? attendance.checkOut,
  );
  context.read<EmployeeDetailCubit>().updateAttendance(updated);
}

DataRow _buildAttendanceRow(
  BuildContext context, {
  required Attendance attendance,
  required bool isClosed,
  required int dayIndex,
}) {
  final tokens = context.almazinTokens;

  return DataRow(
    color: WidgetStateProperty.resolveWith((states) {
      return dayIndex.isEven
          ? tokens.surfaceDefault
          : tokens.surfaceContainer;
    }),
    cells: [
      DataCell(Text(_dayNames[dayIndex])),
      DataCell(Text('${attendance.date.day}/${attendance.date.month}')),
      DataCell(
        isClosed
            ? Text(_formatTime(attendance.checkIn))
            : AttendanceTimePicker(
                label: 'الحضور',
                value: attendance.checkIn,
                onChanged: (time) {
                  _updateAttendance(context, attendance, checkIn: time);
                },
              ),
      ),
      DataCell(
        isClosed
            ? Text(_formatTime(attendance.checkOut))
            : AttendanceTimePicker(
                label: 'الانصراف',
                value: attendance.checkOut,
                onChanged: (time) {
                  _updateAttendance(context, attendance, checkOut: time);
                },
              ),
      ),
      DataCell(
        Text(
          attendance.isComplete
              ? '${attendance.calculatedHours.toStringAsFixed(1)} ساعة'
              : '--',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: attendance.isComplete
                ? tokens.textPrimary
                : tokens.textTertiary,
          ),
        ),
      ),
      DataCell(
        Text(
          attendance.isComplete
              ? formatEgp(attendance.calculatedPay)
              : '--',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: attendance.isComplete
                ? tokens.successColor
                : tokens.textTertiary,
          ),
        ),
      ),
      DataCell(_StatusBadge(isComplete: attendance.isComplete)),
      DataCell(
        isClosed
            ? const SizedBox.shrink()
            : IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: tokens.errorColor),
                onPressed: attendance.id.isEmpty
                    ? null
                    : () => context
                        .read<EmployeeDetailCubit>()
                        .deleteAttendance(attendance.id),
                tooltip: 'حذف',
              ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isComplete});

  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isComplete ? tokens.successColor : tokens.warningColor)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isComplete ? 'مكتمل' : 'غير مكتمل',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isComplete ? tokens.successColor : tokens.warningColor,
        ),
      ),
    );
  }
}
