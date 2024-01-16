import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/services_provider.dart';

mixin ServiceFinderMixin {
  ServicesProvider getServices(BuildContext context) =>
      context.read<ServicesProvider>();
  T getService<T>(BuildContext context) => getServices(context).get<T>();
}

mixin ServiceFinderWidgetMixin<S extends StatefulWidget> on State<S> {
  ServicesProvider get services => context.read<ServicesProvider>();
  T getService<T>() => services.get<T>();
}
