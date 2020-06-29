import 'package:an_flutter_state/src/base_state.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class BaseConsumerView<T extends BaseState> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;

  BaseConsumerView({this.builder, this.onModelReady});

  @override
  _BaseConsumerViewState<T> createState() => _BaseConsumerViewState<T>();
}

class _BaseConsumerViewState<T extends BaseState> extends State<BaseConsumerView<T>> {
  T model = GetIt.instance<T>();

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => model,
      child: Consumer<T>(builder: widget.builder),
    );
  }
}

class BaseSelectorView<T extends BaseState, O> extends StatefulWidget {
  final Widget Function(BuildContext context, O model, Widget child) builder;
  final O Function(BuildContext, T) selector;
  final Function(T) onModelReady;

  BaseSelectorView({this.builder, this.selector, this.onModelReady});

  @override
  _BaseSelectorViewState<T, O> createState() => _BaseSelectorViewState<T, O>();
}

class _BaseSelectorViewState<T extends BaseState, O> extends State<BaseSelectorView<T, O>> {
  T model = GetIt.instance<T>();

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => model,
      child: Selector(
        selector: widget.selector,
        builder: widget.builder,
      ),
    );
  }
}
