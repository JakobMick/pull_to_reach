import 'package:collection/collection.dart' show IterableExtension;
import 'package:meta/meta.dart';
import 'package:pull_to_reach/index_calculator/range.dart';
import 'package:pull_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_to_reach/util.dart';

@immutable
class IndexCalculation {
  final int index;

  //final double percentToNextIndex;

  //TODO implement percentToNextIndex
  IndexCalculation(this.index);

  factory IndexCalculation.empty() => IndexCalculation(-1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexCalculation &&
          runtimeType == other.runtimeType &&
          index == other.index;

  @override
  int get hashCode => index.hashCode;
}

abstract class IndexCalculator {
  IndexCalculation getIndexForScrollPercent(double scrollPercent);

  // -----
  // Factories
  // -----

  factory IndexCalculator({
    double minScrollPosition = 0,
    double maxScrollPosition = 1,
    required List<WeightedIndex> indices,
  }) =>
      _IndexCalculatorImpl(
        minScrollPosition,
        maxScrollPosition,
        indices,
      );
}

class _IndexCalculatorImpl implements IndexCalculator {
  final double minScrollPosition;
  final double maxScrollPosition;

  final List<WeightedIndex> indices;
  late List<Range> _ranges;

  _IndexCalculatorImpl(
      this.minScrollPosition, this.maxScrollPosition, this.indices) {
    _ranges = _createRanges(indices, minScrollPosition, maxScrollPosition);
  }

  @override
  IndexCalculation getIndexForScrollPercent(double scrollPercent) {
    var range = _ranges.firstWhereOrNull(
      (range) => range.isInRange(scrollPercent),
    );

    var index = range?.index ?? -1;
    return IndexCalculation(index);
  }

  List<Range> _createRanges(
      List<WeightedIndex> indices, double min, double max) {
    var count = indices.length;

    List<Range> ranges = [];

    double previousEnd = 0;
    for (int i = 0; i < count; i++) {
      var isFirst = i == 0;
      var isLast = i == count - 1;

      var currentIndex = indices[i];

      double start;
      if (isFirst) {
        start = double.negativeInfinity;
      } else {
        start = previousEnd;
      }

      double end;
      if (isLast) {
        end = double.infinity;
      } else {
        var rangeSize = _rangeSizeForIndex(
          index: currentIndex,
          other: indices,
          maxValue: maxScrollPosition,
        );

        end = previousEnd + rangeSize;
      }

      ranges.add(
        Range(currentIndex.index, start, end),
      );

      previousEnd = end;
    }

    return ranges;
  }

  double _rangeSizeForIndex(
      {required WeightedIndex index,
      required List<WeightedIndex> other,
      required double maxValue}) {
    var weightSum = sum<WeightedIndex>(
      items: other,
      mapper: (index) => index.weight,
    );

    var weightPercent = weightSum / index.weight;
    return maxValue / weightPercent;
  }
}
