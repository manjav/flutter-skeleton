import 'package:flutter/material.dart';
import '../../app_export.dart';

mixin ServiceFinderWidgetMixin<S extends StatefulWidget> on State<S> {
  ServicesProvider get services => serviceLocator<ServicesProvider>();
}
