import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Web uyumlu bir SingleTickerProviderStateMixin implementasyonu
/// Bu sınıf, Flutter web'de yaşanan SingleTickerProviderStateMixin 
/// hatalarını çözmek için kullanılır
///
/// Normal State sınıflarında kullanılabilir:
/// ```dart
/// class MyState extends State<MyWidget> with SafeSingleTickerProviderStateMixin {
///   late TabController _tabController;
///
///   @override
///   void initState() {
///     super.initState();
///     _tabController = TabController(length: 3, vsync: this);
///   }
/// }
/// ```
mixin SafeSingleTickerProviderStateMixin<T extends StatefulWidget> on State<T> implements TickerProvider {
  Ticker? _ticker;

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticker?.muted = !TickerMode.of(context);
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(_ticker == null, 'Bu mixin, sadece tek bir Ticker oluşturulması içindir.');
    _ticker = Ticker(
      onTick,
      debugLabel: kDebugMode ? 'Oluşturan: ${widget.runtimeType}' : null,
    );
    return _ticker!;
  }
  
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    String? tickerDescription;
    if (_ticker != null) {
      if (_ticker!.isActive) {
        tickerDescription = 'aktif';
      } else if (_ticker!.muted) {
        tickerDescription = 'sessiz';
      } else {
        tickerDescription = 'durgun';
      }
    }
    properties.add(DiagnosticsProperty<String>('ticker', tickerDescription, defaultValue: null));
  }
  
  @override
  void activate() {
    super.activate();
  }
}

/// Web derleme hataları için standart State sınıfında da kullanılabilecek TickerProvider
mixin StateTickerProviderMixin<T extends StatefulWidget> on State<T> implements TickerProvider {
  Set<Ticker>? _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _tickers ??= <Ticker>{};
    final Ticker result = Ticker(onTick, debugLabel: 'created by ${widget.runtimeType}');
    _tickers!.add(result);
    return result;
  }

  @override
  void dispose() {
    if (_tickers != null) {
      for (final Ticker ticker in _tickers!) {
        ticker.dispose();
      }
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_tickers != null) {
      final bool muted = !TickerMode.of(context);
      for (final Ticker ticker in _tickers!) {
        ticker.muted = muted;
      }
    }
    super.didChangeDependencies();
  }
}

/// SingleTickerProviderStateMixin yerine State sınıfında kullanılabilen sürüm
mixin StateSingleTickerProviderMixin<T extends StatefulWidget> on State<T> implements TickerProvider {
  Ticker? _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(_ticker == null);
    _ticker = Ticker(onTick, debugLabel: 'created by ${widget.runtimeType}');
    return _ticker!;
  }

  @override
  void dispose() {
    assert(() {
      if (_ticker != null && _ticker!.isActive) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('$this was disposed with an active Ticker.'),
          ErrorDescription(
            'StateSingleTickerProviderMixin requires that dispose() call dispose on the '
            'ticker.'
          ),
          ErrorHint(
            'Tickers used by AnimationControllers '
            'should be disposed by calling dispose() on the AnimationController itself. '
            'Otherwise, the ticker will leak.'
          ),
          _ticker!.describeForError('The offending ticker was'),
        ]);
      }
      return true;
    }());
    if (_ticker != null) {
      _ticker!.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_ticker != null) {
      _ticker!.muted = !TickerMode.of(context);
    }
    super.didChangeDependencies();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    String? tickerDescription;
    if (_ticker != null) {
      if (_ticker!.isActive && _ticker!.muted) {
        tickerDescription = 'active but muted';
      } else if (_ticker!.isActive) {
        tickerDescription = 'active';
      } else if (_ticker!.muted) {
        tickerDescription = 'inactive and muted';
      } else {
        tickerDescription = 'inactive';
      }
    }
    description.add(DiagnosticsProperty<String>('ticker status', tickerDescription, defaultValue: 'no ticker'));
  }
}

/// Helper fonksiyon: Normal bir State için TickerProvider oluşturur
TickerProvider createTickerProvider(State state) {
  return _SimpleTickerProvider(state);
}

class _SimpleTickerProvider implements TickerProvider {
  _SimpleTickerProvider(this._state);
  final State _state;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'created by ${_state.widget.runtimeType}');
  }
}