import 'package:equatable/equatable.dart';

import '../../domain/employee.dart';

enum EmployeesListStatus { initial, loading, ready, failure }

class EmployeesListState extends Equatable {
  const EmployeesListState({
    this.status = EmployeesListStatus.initial,
    this.employees = const [],
    this.errorMessage,
    this.snackbarMessage,
    this.searchQuery = '',
    this.weekStart,
  });

  final EmployeesListStatus status;
  final List<Employee> employees;
  final String? errorMessage;
  final String? snackbarMessage;
  final String searchQuery;
  final DateTime? weekStart;

  List<Employee> get filteredEmployees {
    if (searchQuery.isEmpty) return employees;
    return employees.where((e) {
      return e.name.contains(searchQuery) ||
          (e.phone?.contains(searchQuery) ?? false);
    }).toList();
  }

  int get totalEmployees => employees.length;
  int get activeEmployees => employees.where((e) => e.active).length;

  EmployeesListState copyWith({
    EmployeesListStatus? status,
    List<Employee>? employees,
    String? errorMessage,
    String? snackbarMessage,
    String? searchQuery,
    DateTime? weekStart,
  }) {
    return EmployeesListState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarMessage: snackbarMessage ?? this.snackbarMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  List<Object?> get props => [
        status,
        employees,
        errorMessage,
        snackbarMessage,
        searchQuery,
        weekStart,
      ];
}
