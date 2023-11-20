import 'package:flutter/widgets.dart';

bool wideModeActive(BuildContext context) =>
    MediaQuery.of(context).size.width > 700;
