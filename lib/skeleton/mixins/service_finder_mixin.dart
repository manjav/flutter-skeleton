import 'package:flutter/material.dart';
import 'package:flutter_skeleton/service_locator.dart';
import 'package:provider/provider.dart';

import '../providers/services_provider.dart';

mixin ServiceFinderWidgetMixin<S extends StatefulWidget> on State<S> {
  ServicesProvider get services => serviceLocator<ServicesProvider>();
}
