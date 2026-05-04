import 'package:flutter/material.dart';

/// Global navigator key to allow pushing routes from outside the widget tree
/// (such as from background Firebase Messaging handlers).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
