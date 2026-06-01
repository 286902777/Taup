import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';

class BusTool {
  static BusTool get interest => GetIt.instance<BusTool>();
  final EventBus _eventBus = EventBus();

  /// 发送事件
  static void send(Object data) {
    BusTool.interest._eventBus.fire(data);
  }

  /// 监听事件
  static Stream<T> on<T>() {
    return BusTool.interest._eventBus.on<T>();
  }
}
