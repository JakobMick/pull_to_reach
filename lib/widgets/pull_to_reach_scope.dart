import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_to_reach/reachable_feedback.dart';
import 'package:pull_to_reach/util.dart';
import 'package:pull_to_reach/widgets/scroll_to_index_converter.dart';

class PullToReachScope extends StatelessWidget {
  final Widget child;

  final List<WeightedIndex> indices;
  final ReachableFeedback feedback;
  final double dragExtentPercentage;

  PullToReachScope({
    @required this.child,
    @required this.indices,
    this.feedback,
    this.dragExtentPercentage = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return PullToReachContext(
      indices: indices,
      child: ScrollToIndexConverter(
        child: child,
        dragExtentPercentage: dragExtentPercentage,
      ),
      onFocusChanged: (index) => feedback?.onFocus(index),
      onSelectChanged: (index) => feedback?.onSelect(index),
    );
  }
}

class PullToReachContext extends InheritedWidget {
  // -----
  // Public
  // -----

  Stream<int> get focusIndex => _focusIndex.stream;

  Stream<int> get selectIndex => _selectIndex.stream;

  Stream<double> get dragPercent => _dragPercent.stream;

  List<WeightedIndex> get indices {
    if (_indices != null) return List.from(_indices);

    return mapIndex(
      end: _indexCount,
      mapper: (index) => WeightedIndex(index: index),
    );
  }

  final ValueChanged<int> onFocusChanged;

  final ValueChanged<int> onSelectChanged;

  // -----
  // Private
  // -----

  final StreamController<int> _focusIndex = StreamController.broadcast();

  final StreamController<int> _selectIndex = StreamController.broadcast();

  final StreamController<double> _dragPercent = StreamController.broadcast();

  final List<WeightedIndex> _indices;
  final int _indexCount;

  PullToReachContext({
    Key key,
    @required Widget child,
    List<WeightedIndex> indices,
    int indexCount,
    this.onFocusChanged,
    this.onSelectChanged,
  })  : _indices = indices,
        _indexCount = indexCount,
        assert(indices == null || indexCount == null,
            "Either specify the amount of indeces with count or indices!"),
        super(key: key, child: child);

  static PullToReachContext of(BuildContext context) =>
      //context.inheritFromWidgetOfExactType(PullToReachContext)
      context.dependOnInheritedWidgetOfExactType<PullToReachContext>()
          as PullToReachContext;

  void setFocusIndex(int index) {
    if (onFocusChanged != null) onFocusChanged(index);
    _focusIndex.add(index);
  }

  void setSelectIndex(int index) {
    if (onSelectChanged != null) onSelectChanged(index);
    _selectIndex.add(index);
  }

  void setDragPercent(double percent) => _dragPercent.add(percent);

  @override
  bool updateShouldNotify(PullToReachContext old) => true;
}
