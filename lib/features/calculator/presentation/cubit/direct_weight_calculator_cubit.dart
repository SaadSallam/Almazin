import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:almazin_app/features/calculator/data/customer_blend_drafts_datasource.dart';
import 'package:almazin_app/features/calculator/domain/customer_percentage_blend_draft.dart';
import 'package:almazin_app/features/calculator/domain/direct_weight_calculator_service.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_prices_repository.dart';
import 'package:almazin_app/features/coffee_prices/domain/price_input_parser.dart';

import 'direct_weight_calculator_state.dart';

class DirectWeightCalculatorCubit extends Cubit<DirectWeightCalculatorState> {
  DirectWeightCalculatorCubit({
    required CoffeePricesRepository coffeePricesRepository,
    required CustomerBlendDraftsDataSource draftsDataSource,
    DirectWeightCalculatorService calculator = const DirectWeightCalculatorService(),
  })  : _coffeePricesRepository = coffeePricesRepository,
        _draftsDataSource = draftsDataSource,
        _calculator = calculator,
        super(
          DirectWeightCalculatorState(
            lines: [CalculatorLineDraft(id: Uuid().v4())],
          ),
        );

  final CoffeePricesRepository _coffeePricesRepository;
  final CustomerBlendDraftsDataSource _draftsDataSource;
  final DirectWeightCalculatorService _calculator;

  static final Uuid _uuid = Uuid();

  Future<void> loadCoffees() async {
    emit(
      state.copyWith(
        status: DirectWeightCalculatorStatus.loading,
        errorMessage: null,
        snackbarMessage: null,
      ),
    );
    try {
      final coffees = await _coffeePricesRepository.getAll();
      emit(
        state.copyWith(
          status: DirectWeightCalculatorStatus.ready,
          coffees: coffees,
          errorMessage: null,
        ),
      );
      _recalculate();
    } catch (_) {
      emit(
        state.copyWith(
          status: DirectWeightCalculatorStatus.failure,
          errorMessage: 'تعذر تحميل أسعار البن',
        ),
      );
    }
  }

  void clearSnackbar() {
    emit(state.copyWith(snackbarMessage: null));
  }

  void addLine() {
    final next = List<CalculatorLineDraft>.from(state.lines)
      ..add(CalculatorLineDraft(id: _uuid.v4()));
    emit(state.copyWith(lines: next));
    _recalculate();
  }

  void removeLine(String lineId) {
    if (state.lines.length <= 1) return;
    final next = state.lines.where((l) => l.id != lineId).toList();
    emit(state.copyWith(lines: next));
    _recalculate();
  }

  void setCoffee(String lineId, String? coffeeId) {
    final next = state.lines
        .map((l) => l.id == lineId ? l.copyWith(coffeeId: coffeeId) : l)
        .toList();
    emit(state.copyWith(lines: next));
    _recalculate();
  }

  void setWeightInput(String lineId, String raw) {
    final next = state.lines
        .map((l) => l.id == lineId ? l.copyWith(weightInput: raw) : l)
        .toList();
    emit(state.copyWith(lines: next));
    _recalculate();
  }

  void _recalculate() {
    final map = {for (final c in state.coffees) c.id: c};
    final inputs = <DirectWeightLineInput>[];

    for (final line in state.lines) {
      final id = line.coffeeId;
      if (id == null || id.isEmpty) continue;
      final grams = PriceInputParser.tryParse(line.weightInput) ?? 0;
      if (grams <= 0) continue;
      inputs.add(DirectWeightLineInput(coffeeId: id, weightGrams: grams));
    }

    final result = _calculator.calculate(lines: inputs, coffeesById: map);
    emit(state.copyWith(result: result));
  }

  Future<bool> saveCurrentAsPercentageBlend(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'يرجى إدخال اسم للتوليفة'));
      return false;
    }

    if (state.result.lines.isEmpty) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'لا يوجد حساب صالح للحفظ'));
      return false;
    }

    try {
      final rawComponents = state.result.lines
          .map(
            (l) => BlendPercentComponent(
              coffeeId: l.coffeeId,
              percent: l.weightPercent,
            ),
          )
          .toList();

      final sum = rawComponents.fold<double>(0, (a, b) => a + b.percent);
      final normalized = sum > 0
          ? rawComponents
              .map(
                (c) => BlendPercentComponent(
                  coffeeId: c.coffeeId,
                  percent: (c.percent / sum) * 100,
                ),
              )
              .toList()
          : rawComponents;

      final draft = CustomerPercentageBlendDraft(
        id: _uuid.v4(),
        title: trimmed,
        createdAt: DateTime.now(),
        components: normalized,
      );

      await _draftsDataSource.append(draft);
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'تم حفظ التوليفة كنسب مئوية'));
      return true;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'تعذر حفظ التوليفة'));
      return false;
    }
  }
}
