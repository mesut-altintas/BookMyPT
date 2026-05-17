import 'dart:async';

import 'package:flutter/foundation.dart';

/// Returns a [StreamTransformer] that converts any stream error into an
/// empty-list emission, preventing [StreamProvider] from getting stuck
/// in the loading state forever when a Firestore permission error occurs.
StreamTransformer<List<T>, List<T>> safeList<T>() =>
    StreamTransformer.fromHandlers(
      handleError: (error, stack, sink) {
        if (kDebugMode) debugPrint('[safeList<$T>] stream error: $error');
        sink.add(<T>[]);
      },
    );

/// Returns a [StreamTransformer] that converts any stream error into a
/// null emission for nullable single-value providers.
StreamTransformer<T?, T?> safeNullable<T>() =>
    StreamTransformer.fromHandlers(
      handleError: (error, stack, sink) {
        if (kDebugMode) debugPrint('[safeNullable<$T>] stream error: $error');
        sink.add(null);
      },
    );
