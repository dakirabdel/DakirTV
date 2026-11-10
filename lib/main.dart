import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'api.dart';

// ---------------------------------------------------------------------------
// Brand
// ---------------------------------------------------------------------------

const _bg = Color(0xFF07070C);
const _surface = Color(0xFF111118);
const _surface2 = Color(0xFF181822);
const _accent = Color(0xFFF43F5E);
const _accent2 = Color(0xFFFF7A45);
const _textDim = Color(0xFF9CA3AF);
const _defaultCode = '232425';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DakirApp());
}

class DakirApp extends StatelessWidget {
  const DakirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DakirTV',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: const SplashGate(),
    );
  }

  ThemeData _theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _accent,
      secondary: _accent2,
      surface: _surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bg,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surface2,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _accent.withValues(alpha: 0.18),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : _textDim,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? _accent : _textDim,
            size: 24,
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Splash
// ---------------------------------------------------------------------------

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showCode = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1850), () {
      if (mounted) setState(() => _showCode = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _showCode
          ? const CodeScreen(key: ValueKey('code'))
          : const SplashScreen(key: ValueKey('splash')),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF14070F), _bg, _bg],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -110,
              left: -90,
              child: _Glow(color: _accent.withValues(alpha: 0.22), size: 320),
            ),
            Positioned(
              bottom: -120,
              right: -100,
              child: _Glow(color: _accent2.withValues(alpha: 0.14), size: 340),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: Transform.scale(
                        scale: 0.9 + 0.1 * value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LogoMark(size: 104),
                    const SizedBox(height: 28),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFB3C1)],
                      ).createShader(bounds),
                      child: const Text(
                        'DakirTV',
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.8,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Live television, reimagined.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _accent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 34,
              child: Text(
                'Your code · Your channels',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Code screen
// ---------------------------------------------------------------------------

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final DramaApi _api = DramaApi();
  final List<String> _savedCodes = <String>[_defaultCode];
  String _selectedCode = _defaultCode;
  bool _loading = false;
  bool _booting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _api.init();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_codes') ?? const <String>[];
    final codes = <String>[
      _defaultCode,
      ...saved.where((code) => code.trim().isNotEmpty && code != _defaultCode),
    ];
    final last = prefs.getString('selected_code');
    if (!mounted) return;
    setState(() {
      _savedCodes
        ..clear()
        ..addAll(codes);
      _selectedCode = last != null && codes.contains(last) ? last : _defaultCode;
      _booting = false;
    });
  }

  Future<void> _persistCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_codes', _savedCodes);
  }

  Future<void> _continue() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final activated = await _api.activate(_selectedCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_code', activated);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HomeShell(api: _api, code: activated),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addCode() async {
    final controller = TextEditingController();
    final entered = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Material(
            color: _surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _SheetHandle()),
                    const SizedBox(height: 18),
                    const Text(
                      'Add a new code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter the access code you received. You can switch codes at any time.',
                      style: TextStyle(fontSize: 12.5, color: _textDim),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                      ),
                      onSubmitted: (value) =>
                          Navigator.of(sheetContext).pop(value.trim()),
                      decoration: InputDecoration(
                        hintText: 'e.g. 232425',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(controller.text.trim()),
                        child: const Text('Add code'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    controller.dispose();

    final code = entered?.trim() ?? '';
    if (code.isEmpty || !mounted) return;
    setState(() {
      if (!_savedCodes.contains(code)) _savedCodes.add(code);
      _selectedCode = code;
    });
    await _persistCodes();
  }

  Future<void> _removeCode(String code) async {
    if (code == _defaultCode) return;
    setState(() {
      _savedCodes.remove(code);
      if (_selectedCode == code) _selectedCode = _defaultCode;
    });
    await _persistCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF12070D), _bg, _bg],
            stops: [0, 0.45, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              right: -100,
              child: _Glow(color: _accent.withValues(alpha: 0.16), size: 320),
            ),
            SafeArea(
              child: _booting
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const _LogoMark(size: 46),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'DakirTV',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                ),
                                _CircleIconButton(
                                  icon: Icons.refresh_rounded,
                                  tooltip: 'Reload',
                                  onTap: _bootstrap,
                                ),
                              ],
                            ),
                            const SizedBox(height: 34),
                            const Text(
                              'Choose your code',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pick the default code or add a new one. Your selection is saved for next time.',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: _textDim,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 24),
                            for (final code in _savedCodes) ...[
                              _CodeCard(
                                code: code,
                                selected: code == _selectedCode,
                                isDefault: code == _defaultCode,
                                onTap: () =>
                                    setState(() => _selectedCode = code),
                                onRemove: code == _defaultCode
                                    ? null
                                    : () => _removeCode(code),
                              ),
                              const SizedBox(height: 10),
                            ],
                            _AddCodeCard(onTap: _addCode),
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              _InlineError(message: _error!),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 56,
                              child: FilledButton(
                                onPressed: _loading ? null : _continue,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Connecting…'),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Continue with $_selectedCode',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'DakirTV is a media player. It does not host or supply any content. '
                              'Use only codes and streams you are authorised to access.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.32),
                              ),
                            ),
                          ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.code,
    required this.selected,
    required this.isDefault,
    required this.onTap,
    this.onRemove,
  });

  final String code;
  final bool selected;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selected
            ? _accent.withValues(alpha: 0.12)
            : _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? _accent.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.06),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(colors: [_accent, _accent2])
                        : null,
                    color: selected ? null : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.vpn_key_rounded,
                    size: 21,
                    color: selected ? Colors.white : _textDim,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              code,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: _textDim,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selected ? 'Selected' : 'Tap to select',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: selected ? _accent : _textDim,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Remove code',
                    visualDensity: VisualDensity.compact,
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          key: ValueKey('selected'),
                          color: _accent,
                          size: 24,
                        )
                      : const Icon(
                          Icons.circle_outlined,
                          key: ValueKey('unselected'),
                          color: Colors.white24,
                          size: 24,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCodeCard extends StatelessWidget {
  const _AddCodeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.add_rounded, color: _textDim),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Add a new code',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home shell with bottom navigation
// ---------------------------------------------------------------------------

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.api, required this.code});

  final DramaApi api;
  final String code;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomeTab(
            api: widget.api,
            code: widget.code,
            onSwitchCode: () => Navigator.of(context).maybePop(),
          ),
          LiveTab(
            api: widget.api,
            code: widget.code,
            onSwitchCode: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer_rounded),
            label: 'Live',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home tab
// ---------------------------------------------------------------------------

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.api,
    required this.code,
    required this.onSwitchCode,
  });

  final DramaApi api;
  final String code;
  final VoidCallback onSwitchCode;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  List<Topic> _topics = const [];
  List<Channel> _channels = const [];
  String? _selectedTopic;
  bool _loadingTopics = true;
  bool _loadingChannels = false;
  bool _searchOpen = false;
  String _query = '';
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Topic> _ordered(List<Topic> topics) {
    const priority = ['hot_now', 'bein_sport', '212'];
    final result = <Topic>[];
    final byId = {for (final topic in topics) topic.id: topic};
    for (final id in priority) {
      final topic = byId.remove(id);
      if (topic != null) result.add(topic);
    }
    for (final topic in topics) {
      if (topic.id == 'live_matches') continue;
      if (byId.containsKey(topic.id)) {
        result.add(byId.remove(topic.id)!);
      }
    }
    return result;
  }

  Future<void> _load() async {
    setState(() {
      _loadingTopics = true;
      _error = null;
    });
    try {
      final topics = _ordered(await widget.api.topics());
      if (!mounted) return;
      setState(() {
        _topics = topics;
        _loadingTopics = false;
      });
      if (topics.isNotEmpty) {
        await _selectTopic(topics.first.id);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingTopics = false;
        _error = '$error';
      });
    }
  }

  Future<void> _selectTopic(String topicId) async {
    final request = ++_requestId;
    setState(() {
      _selectedTopic = topicId;
      _loadingChannels = true;
      _error = null;
    });
    try {
      final channels = await widget.api.channels(topicId);
      if (!mounted || request != _requestId) return;
      setState(() {
        _channels = channels;
        _loadingChannels = false;
      });
    } catch (error) {
      if (!mounted || request != _requestId) return;
      setState(() {
        _loadingChannels = false;
        _error = '$error';
      });
    }
  }

  Future<void> _refresh() async {
    final topic = _selectedTopic;
    if (topic != null && _topics.isNotEmpty) {
      await _selectTopic(topic);
    } else {
      await _load();
    }
  }

  List<Channel> get _visibleChannels {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _channels;
    return _channels
        .where((channel) => channel.name.toLowerCase().contains(query))
        .toList();
  }

  String get _selectedTopicName {
    final id = _selectedTopic;
    if (id == null) return 'Channels';
    for (final topic in _topics) {
      if (topic.id == id) return topic.name;
    }
    return 'Channels';
  }

  void _openChannel(Channel channel) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(
          api: widget.api,
          channel: channel,
          channels: _channels,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleChannels;

    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 10, 4),
              child: _HomeHeader(
                code: widget.code,
                onSearch: () {
                  setState(() {
                    _searchOpen = !_searchOpen;
                    if (!_searchOpen) {
                      _searchController.clear();
                      _query = '';
                    }
                  });
                },
                onSwitchCode: widget.onSwitchCode,
                onRefresh: _load,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _searchOpen
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'Search channels…',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                          filled: true,
                          fillColor: _surface,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 42,
              child: _loadingTopics && _topics.isEmpty
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: _topics.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final topic = _topics[index];
                        final selected = topic.id == _selectedTopic;
                        return _TopicChip(
                          label: topic.name,
                          selected: selected,
                          onTap: () {
                            if (topic.id == _selectedTopic) return;
                            _selectTopic(topic.id);
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTopicName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Text(
                    _loadingChannels ? 'Loading…' : '${visible.length} channels',
                    style: const TextStyle(fontSize: 11.5, color: _textDim),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: _accent,
                backgroundColor: _surface,
                child: _buildGrid(visible),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Channel> visible) {
    if (_error != null && _channels.isEmpty) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load channels',
        message: _error,
        onRetry: _load,
      );
    }
    if (_loadingChannels && _channels.isEmpty) {
      return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 2, 18, 110),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 172,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: 8,
        itemBuilder: (_, _) => const _ChannelSkeleton(),
      );
    }
    if (visible.isEmpty) {
      return _EmptyState(
        icon: _query.isEmpty ? Icons.tv_off_rounded : Icons.search_off_rounded,
        title: _query.isEmpty ? 'No channels here' : 'No matches for "$_query"',
        message: _query.isEmpty
            ? 'Try another filter or pull down to refresh.'
            : 'Try a different channel name.',
        onRetry: _refresh,
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 110),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 172,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final channel = visible[index];
        return _ChannelCard(
          channel: channel,
          onTap: () => _openChannel(channel),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.code,
    required this.onSearch,
    required this.onSwitchCode,
    required this.onRefresh,
  });

  final String code;
  final VoidCallback onSearch;
  final VoidCallback onSwitchCode;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LogoMark(size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DakirTV',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Code $code',
                style: const TextStyle(fontSize: 11.5, color: _textDim),
              ),
            ],
          ),
        ),
        _CircleIconButton(
          icon: Icons.search_rounded,
          tooltip: 'Search',
          onTap: onSearch,
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          tooltip: 'More',
          color: _surface2,
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
          onSelected: (value) {
            if (value == 'refresh') onRefresh();
            if (value == 'switch') onSwitchCode();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.refresh_rounded, size: 20),
                title: Text('Refresh'),
              ),
            ),
            PopupMenuItem(
              value: 'switch',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.vpn_key_rounded, size: 20),
                title: Text('Switch code'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? _accent.withValues(alpha: 0.16) : _surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? _accent.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : _textDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.channel, required this.onTap});

  final Channel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(9, 9, 9, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.035),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: _ChannelLogo(
                          url: channel.image,
                          name: channel.name,
                          size: 74,
                          radius: 10,
                        ),
                      ),
                    ),
                    const Positioned(top: 14, left: 14, child: _LiveDot()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Row(
                      children: [
                        Icon(Icons.play_circle_fill_rounded,
                            size: 13, color: _accent),
                        SizedBox(width: 4),
                        Text(
                          'Watch live',
                          style: TextStyle(fontSize: 10, color: _textDim),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelSkeleton extends StatelessWidget {
  const _ChannelSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(9, 9, 9, 0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  height: 8,
                  width: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live tab
// ---------------------------------------------------------------------------

class LiveTab extends StatefulWidget {
  const LiveTab({
    super.key,
    required this.api,
    required this.code,
    required this.onSwitchCode,
  });

  final DramaApi api;
  final String code;
  final VoidCallback onSwitchCode;

  @override
  State<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<LiveTab> {
  List<Match> _matches = const [];
  Map<String, Channel> _channelsById = const {};
  bool _loading = true;
  String? _error;
  String? _opening;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches = await widget.api.matches();
      final ids = matches
          .map((match) => match.channel.trim())
          .where((id) => id.isNotEmpty)
          .toSet();
      Map<String, Channel> channels = const {};
      if (ids.isNotEmpty) {
        try {
          final list = await widget.api.channelsByIds(ids);
          channels = {for (final channel in list) channel.id: channel};
        } catch (_) {
          // Matches still work; the player can resolve the channel on tap.
        }
      }
      if (!mounted) return;
      final ordered = [...matches];
      ordered.sort((a, b) {
        if (a.isPlayingNow == b.isPlayingNow) return 0;
        return a.isPlayingNow ? -1 : 1;
      });
      setState(() {
        _matches = ordered;
        _channelsById = channels;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _openMatch(Match match) async {
    if (!match.isAvailable) {
      _toast('This broadcast is not available yet.');
      return;
    }
    if (_opening != null) return;

    var channel = _channelsById[match.channel];
    if (channel == null) {
      setState(() => _opening = match.title);
      try {
        final id = match.channel.trim().isEmpty
            ? 'live_tv_beinsport1'
            : match.channel.trim();
        final list = await widget.api.channelsByIds([id]);
        if (list.isNotEmpty) channel = list.first;
      } catch (_) {
        // Fall through to the error message below.
      }
      if (!mounted) return;
      setState(() => _opening = null);
    }

    if (channel == null) {
      _toast('Could not find the channel for this match.');
      return;
    }

    final selected = channel;
    final siblings = _channelsById.values.toList();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(
          api: widget.api,
          channel: selected,
          channels: siblings.isEmpty ? [selected] : siblings,
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _channelLabel(String id) {
    if (id.trim().isEmpty) return 'Bein S. 1';
    final channel = _channelsById[id];
    if (channel != null && channel.name.isNotEmpty) return channel.name;
    return id.replaceFirst('live_tv_', '').replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 10, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Matches',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap a match to jump straight to the channel',
                          style: TextStyle(fontSize: 11.5, color: _textDim),
                        ),
                      ],
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Refresh',
                    onTap: _load,
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    color: _surface2,
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.white70),
                    onSelected: (value) {
                      if (value == 'switch') widget.onSwitchCode();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'switch',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.vpn_key_rounded, size: 20),
                          title: Text('Switch code'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                color: _accent,
                backgroundColor: _surface,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _matches.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
        children: const [
          _MatchSkeleton(),
          SizedBox(height: 12),
          _MatchSkeleton(),
          SizedBox(height: 12),
          _MatchSkeleton(),
        ],
      );
    }
    if (_error != null && _matches.isEmpty) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load matches',
        message: _error,
        onRetry: _load,
      );
    }
    if (_matches.isEmpty) {
      return _EmptyState(
        icon: Icons.sports_soccer_rounded,
        title: 'No matches today',
        message: 'Check back later or pull down to refresh.',
        onRetry: _load,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
      children: [
        _MatchDayBanner(count: _matches.length),
        const SizedBox(height: 14),
        for (final match in _matches) ...[
          _MatchCard(
            match: match,
            channelLabel: _channelLabel(match.channel),
            opening: _opening == match.title,
            onTap: () => _openMatch(match),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MatchDayBanner extends StatelessWidget {
  const _MatchDayBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0D18), Color(0xFF160B12)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.sports_soccer_rounded,
                color: _accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match day',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count fixtures · tap any match to watch',
                  style: const TextStyle(fontSize: 11.5, color: _textDim),
                ),
              ],
            ),
          ),
          const _LiveBadge(),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.channelLabel,
    required this.opening,
    required this.onTap,
  });

  final Match match;
  final String channelLabel;
  final bool opening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final score = _scoreText;
    final available = match.isAvailable;

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: opening ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.topic.isEmpty ? 'Football' : match.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: _textDim,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (match.isPlayingNow)
                    const _LiveBadge()
                  else
                    _TimeBadge(text: match.date),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TeamColumn(
                      name: match.firstTeam,
                      image: match.firstTeamImage,
                      alignEnd: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          score,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (!match.isPlayingNow && match.date.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            match.date,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _textDim,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: _TeamColumn(
                      name: match.secondTeam,
                      image: match.secondTeamImage,
                      alignEnd: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  const Icon(Icons.live_tv_rounded, size: 15, color: _textDim),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      channelLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _textDim,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (opening)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (available)
                    FilledButton.icon(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: _accent.withValues(alpha: 0.16),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: _accent.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 17),
                      label: const Text(
                        'Watch',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const Text(
                      'Not available',
                      style: TextStyle(fontSize: 10.5, color: Colors.white38),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _scoreText {
    final first = match.firstTeamScore.trim();
    final second = match.secondTeamScore.trim();
    bool real(String value) =>
        value.isNotEmpty && value != '-' && value.toLowerCase() != 'null';
    if (real(first) && real(second)) return '$first - $second';
    return 'VS';
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.name,
    required this.image,
    required this.alignEnd,
  });

  final String name;
  final String image;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _TeamLogo(url: image, name: name),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.name});

  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: url.isEmpty
          ? const Icon(Icons.shield_outlined, color: Colors.white30)
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.shield_outlined, color: Colors.white30),
            ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final label = text.trim().isEmpty ? 'Today' : text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _textDim,
        ),
      ),
    );
  }
}

class _MatchSkeleton extends StatelessWidget {
  const _MatchSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Player
// ---------------------------------------------------------------------------

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.api,
    required this.channel,
    this.channels = const [],
  });

  final DramaApi api;
  final Channel channel;
  final List<Channel> channels;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Channel _channel;
  late List<Channel> _channels;

  List<ServerOption> _servers = const [];
  int _selected = 0;
  StreamInfo? _info;
  VideoPlayerController? _controller;
  WebViewController? _webController;

  bool _loadingServers = true;
  bool _connecting = false;
  bool _switching = false;
  bool _fullscreen = false;
  bool _showControls = true;
  bool _channelsOpen = false;
  bool _layoutInit = false;
  String? _error;

  final Set<int> _tried = <int>{};
  Duration _lastPosition = Duration.zero;
  DateTime _lastProgressAt = DateTime.now();
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    _channel = widget.channel;
    _channels = widget.channels.isEmpty ? [widget.channel] : widget.channels;
    _watchdog = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkStall(),
    );
    _loadServers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_layoutInit) return;
    _layoutInit = true;
    // TV and tablet layouts open the channel rail by default.
    final size = MediaQuery.sizeOf(context);
    // Open the rail by default only on tablet/TV sized screens where there is
    // enough vertical room left for the video.
    _channelsOpen = size.width >= 840 && size.height >= 620;
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    _webController = null;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _loadServers() async {
    setState(() {
      _loadingServers = true;
      _error = null;
      _servers = const [];
      _selected = 0;
      _tried.clear();
    });
    try {
      final all = await widget.api.servers(_channel);
      final list = all;
      if (!mounted) return;
      if (list.isEmpty) {
        setState(() {
          _loadingServers = false;
          _error = 'No servers found for this channel.';
        });
        return;
      }
      setState(() {
        _servers = list;
        _loadingServers = false;
      });
      await _openServer(0, auto: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingServers = false;
        _error = 'Could not load the server list.';
      });
    }
  }

  Future<void> _openServer(int index, {required bool auto}) async {
    if (_switching) return;
    if (index < 0 || index >= _servers.length) return;

    _switching = true;
    final server = _servers[index];
    setState(() {
      _selected = index;
      _connecting = true;
      _error = null;
      _info = null;
      _showControls = true;
    });
    await _disposeController();
    await _disposeWebPlayer();

    VideoPlayerController? controller;
    try {
      final info = await widget.api.resolveServer(_channel, server);
      if (info == null || info.format == 'web') {
        _tried.add(index);
        _switching = false;
        await _handleFailure(
          auto: auto,
          message: info?.format == 'web'
              ? 'This server needs a web player.'
              : 'Could not connect to server ${server.index}.',
        );
        return;
      }

      if (info.format == 'youtube') {
        final videoId = youTubeId(info.url);
        if (videoId == null) {
          _tried.add(index);
          _switching = false;
          await _handleFailure(
            auto: auto,
            message: 'Could not read this YouTube stream.',
          );
          return;
        }
        final web = await _createWebPlayer(videoId);
        if (!mounted) return;
        _tried.clear();
        setState(() {
          _webController = web;
          _info = info;
          _connecting = false;
          _error = null;
          _showControls = true;
        });
        _switching = false;
        return;
      }

      controller = VideoPlayerController.networkUrl(
        Uri.parse(info.url),
        httpHeaders: info.headers,
        formatHint: _videoFormat(info.format),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await controller.initialize();
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      controller.addListener(_onControllerChanged);
      _tried.clear();
      setState(() {
        _controller = controller;
        _info = info;
        _connecting = false;
        _error = null;
        _lastPosition = Duration.zero;
        _lastProgressAt = DateTime.now();
      });
      _switching = false;
    } catch (_) {
      await controller?.dispose();
      _tried.add(index);
      _switching = false;
      await _handleFailure(
        auto: auto,
        message: 'Server ${server.index} is not responding.',
      );
    }
  }

  Future<void> _disposeController() async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      old.removeListener(_onControllerChanged);
      await old.dispose();
    }
  }

  Future<void> _disposeWebPlayer() async {
    final old = _webController;
    _webController = null;
    if (old != null) {
      try {
        await old.loadRequest(Uri.parse('about:blank'));
      } catch (_) {
        // The platform view may already be gone; nothing else to release.
      }
    }
  }

  Future<WebViewController> _createWebPlayer(String videoId) async {
    final controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.black);
    // A plain Chrome mobile user agent: YouTube refuses playback when it sees
    // the `wv` WebView marker.
    await controller.setUserAgent(
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36',
    );
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      await platform.setMediaPlaybackRequiresUserGesture(false);
    }
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          // The mobile site puts its top bar above the player; hide it so the
          // video fills the player area.
          controller.runJavaScript('''
(function () {
  var style = document.getElementById('dakirtv-style');
  if (!style) {
    style = document.createElement('style');
    style.id = 'dakirtv-style';
    document.head.appendChild(style);
  }
  style.textContent =
    'ytm-mobile-topbar-renderer, ytm-app-header, #masthead-container, .mobile-topbar-header { display: none !important; }' +
    'html, body { background: #000 !important; }';
  window.scrollTo(0, 0);
})();
''');
        },
      ),
    );
    await controller.loadRequest(
      Uri.parse(
        'https://m.youtube.com/watch?v=$videoId&autoplay=1&playsinline=1',
      ),
      headers: const {'Referer': 'https://www.youtube.com/'},
    );
    return controller;
  }

  Future<void> _handleFailure({
    required bool auto,
    String? message,
  }) async {
    if (!mounted) return;
    final next = _nextIndex();
    if (auto && next != null) {
      await _openServer(next, auto: true);
      return;
    }
    setState(() {
      _connecting = false;
      _error = message ?? 'This server is not responding.';
    });
  }

  int? _nextIndex() {
    if (_servers.isEmpty) return null;
    for (var step = 1; step <= _servers.length; step++) {
      final index = (_selected + step) % _servers.length;
      if (!_tried.contains(index)) return index;
    }
    return null;
  }

  Future<void> _selectServer(int index) async {
    if (index == _selected &&
        (_controller != null || _webController != null) &&
        !_connecting) {
      return;
    }
    _tried
      ..clear()
      ..add(index);
    await _openServer(index, auto: true);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.hasError && !_switching) {
      _handleFailure(
        auto: true,
        message: controller.value.errorDescription ?? 'Playback error.',
      );
    }
  }

  void _checkStall() {
    if (_info?.format == 'youtube') return;
    final controller = _controller;
    if (!mounted || controller == null || !controller.value.isInitialized) {
      return;
    }
    if (!controller.value.isPlaying || _switching) return;

    final position = controller.value.position;
    if (position != _lastPosition) {
      _lastPosition = position;
      _lastProgressAt = DateTime.now();
      return;
    }
    if (DateTime.now().difference(_lastProgressAt) >
        const Duration(seconds: 20)) {
      _lastProgressAt = DateTime.now();
      _handleFailure(auto: true, message: 'The stream stalled. Switching…');
    }
  }

  VideoFormat? _videoFormat(String? format) {
    switch (format) {
      case 'hls':
        return VideoFormat.hls;
      case 'dash':
        return VideoFormat.dash;
      default:
        return null;
    }
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setVolume(controller.value.volume == 0 ? 1 : 0);
    if (mounted) setState(() {});
  }

  Future<void> _toggleFullscreen() async {
    final next = !_fullscreen;
    setState(() => _fullscreen = next);
    if (next) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  Future<void> _switchChannel(Channel channel) async {
    if (channel.id == _channel.id) return;
    setState(() {
      _channel = channel;
      _servers = const [];
      _selected = 0;
      _info = null;
      _error = null;
      _connecting = false;
      _tried.clear();
    });
    await _disposeController();
    await _disposeWebPlayer();
    await _loadServers();
  }

  void _tryNextServer() {
    if (_servers.isEmpty) return;
    final next = (_selected + 1) % _servers.length;
    _tried.clear();
    _openServer(next, auto: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_fullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _fullscreen) _toggleFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _fullscreen
            ? _buildFullscreen()
            : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 840;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAppBar(wide: wide),
                        _buildServerRow(wide: wide),
                        Expanded(
                          child: _buildVideoStage(),
                        ),
                        _buildChannelsPanel(wide: wide),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildVideoStage() {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildVideoArea(),
      ),
    );
  }

  Widget _buildAppBar({required bool wide}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, wide ? 8 : 4, wide ? 16 : 8, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          _ChannelLogo(
            url: _channel.image,
            name: _channel.name,
            size: wide ? 42 : 36,
            radius: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: wide ? 18 : 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const _LiveBadge(),
          const SizedBox(width: 2),
          _CircleIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Reload servers',
            onTap: _loadServers,
          ),
        ],
      ),
    );
  }

  Widget _buildServerRow({required bool wide}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 20 : 12, 2, wide ? 20 : 8, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: wide ? 46 : 40,
              child: _loadingServers
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _servers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final server = _servers[index];
                        return _ServerChip(
                          server: server,
                          selected: index == _selected,
                          busy: index == _selected && _connecting,
                          onTap: () => _selectServer(index),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 8),
          _NextServerButton(wide: wide, onTap: _tryNextServer),
        ],
      ),
    );
  }

  Widget _buildChannelsPanel({required bool wide}) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        wide ? 18 : 12,
        8,
        wide ? 18 : 12,
        wide ? 14 : 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ChannelsToggle(
                open: _channelsOpen,
                count: _channels.length,
                onTap: () => setState(() => _channelsOpen = !_channelsOpen),
              ),
              const Spacer(),
              if (_channelsOpen)
                Text(
                  '${_channels.length} channels',
                  style: const TextStyle(fontSize: 11, color: _textDim),
                ),
            ],
          ),
          if (_channelsOpen) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: wide ? 128 : 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _channels.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final channel = _channels[index];
                  return _ChannelStripTile(
                    channel: channel,
                    selected: channel.id == _channel.id,
                    wide: wide,
                    onTap: () => _switchChannel(channel),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_info?.format == 'youtube') return _buildWebArea();
    final controller = _controller;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                return GestureDetector(
                  onTap: () =>
                      setState(() => _showControls = !_showControls),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: value.aspectRatio == 0
                              ? 16 / 9
                              : value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                      ),
                      if (_showControls)
                        _buildControls(value),
                      if (_connecting) _buildLoadingOverlay(),
                    ],
                  ),
                );
              },
            )
          else if (_error != null)
            _buildErrorOverlay()
          else
            _buildLoadingOverlay(),
          if (_connecting && controller != null && controller.value.isInitialized)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildWebArea() {
    final web = _webController;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (web != null)
            WebViewWidget(controller: web)
          else
            _buildLoadingOverlay(),
          if (_connecting && web != null) _buildLoadingOverlay(),
          Positioned(
            top: 6,
            right: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.smart_display_rounded,
                        size: 13,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'YouTube',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _toggleFullscreen,
                    iconSize: 19,
                    visualDensity: VisualDensity.compact,
                    tooltip: _fullscreen ? 'Exit fullscreen' : 'Fullscreen',
                    icon: Icon(
                      _fullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _accent,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Connecting…',
              style: TextStyle(fontSize: 12.5, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 38, color: Colors.white38),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: Colors.white70),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                _tried.clear();
                _openServer(_selected, auto: true);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(VideoPlayerValue value) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 20, 6, 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.78),
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _toggleMute,
              icon: Icon(
                value.volume == 0
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                color: Colors.white,
              ),
            ),
            if (value.isBuffering) ...[
              const SizedBox(width: 4),
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ],
            const Spacer(),
            IconButton(
              onPressed: _toggleFullscreen,
              icon: Icon(
                _fullscreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreen() {
    if (_info?.format == 'youtube') return _buildWebArea();
    final controller = _controller;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                return GestureDetector(
                  onTap: () =>
                      setState(() => _showControls = !_showControls),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: value.aspectRatio == 0
                              ? 16 / 9
                              : value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                      ),
                      if (_showControls) _buildControls(value),
                    ],
                  ),
                );
              },
            )
          else if (_error != null)
            _buildErrorOverlay()
          else
            _buildLoadingOverlay(),
          if (_connecting && controller != null && controller.value.isInitialized)
            _buildLoadingOverlay(),
          Positioned(
            top: 14,
            right: 14,
            child: _CircleIconButton(
              icon: Icons.fullscreen_exit_rounded,
              tooltip: 'Exit fullscreen',
              onTap: _toggleFullscreen,
            ),
          ),
        ],
      ),
    );
  }

}

class _ServerChip extends StatelessWidget {
  const _ServerChip({
    required this.server,
    required this.selected,
    required this.busy,
    required this.onTap,
  });

  final ServerOption server;
  final bool selected;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showLabel = server.label != '${server.index}';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(colors: [_accent, _accent2])
            : null,
        color: selected ? null : _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          focusColor: Colors.white.withValues(alpha: 0.14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Text(
                    '${server.index}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : _textDim,
                    ),
                  ),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    server.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _NextServerButton extends StatelessWidget {
  const _NextServerButton({required this.wide, required this.onTap});

  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Next server',
      child: Material(
        color: _accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          focusColor: Colors.white.withValues(alpha: 0.14),
          onTap: onTap,
          child: Container(
            height: wide ? 46 : 40,
            padding: EdgeInsets.symmetric(horizontal: wide ? 14 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.skip_next_rounded, size: 19, color: _accent),
                const SizedBox(width: 4),
                Text(
                  wide ? 'Next server' : 'Next',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelsToggle extends StatelessWidget {
  const _ChannelsToggle({
    required this.open,
    required this.count,
    required this.onTap,
  });

  final bool open;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: open ? _accent.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        focusColor: Colors.white.withValues(alpha: 0.14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.live_tv_rounded,
                size: 16,
                color: open ? _accent : Colors.white70,
              ),
              const SizedBox(width: 7),
              Text(
                'Channels',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: open ? _accent : Colors.white70,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: const TextStyle(fontSize: 11, color: _textDim),
              ),
              const SizedBox(width: 4),
              Icon(
                open
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                size: 18,
                color: open ? _accent : Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelStripTile extends StatelessWidget {
  const _ChannelStripTile({
    required this.channel,
    required this.selected,
    required this.wide,
    required this.onTap,
  });

  final Channel channel;
  final bool selected;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = wide ? 142.0 : 106.0;
    return SizedBox(
      width: width,
      child: Material(
        color: selected
            ? _accent.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          focusColor: Colors.white.withValues(alpha: 0.14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? _accent.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: _ChannelLogo(
                      url: channel.image,
                      name: channel.name,
                      size: wide ? 46 : 40,
                      radius: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  channel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: wide ? 11.5 : 10.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(size * 0.055),
        child: Image.asset(
          'assets/icons/icon_foreground.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withValues(alpha: 0.055),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        focusColor: Colors.white.withValues(alpha: 0.14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 20, color: Colors.white70),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _ChannelLogo extends StatelessWidget {
  const _ChannelLogo({
    required this.url,
    required this.name,
    required this.size,
    this.radius = 12,
  });

  final String url;
  final String name;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: url.isEmpty
          ? _fallback()
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Center(
      child: Icon(
        Icons.tv_rounded,
        size: size * 0.42,
        color: Colors.white30,
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: _accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _accent, blurRadius: 6, spreadRadius: 1),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LiveDot(),
          SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: _accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFFFFA3B5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 60, 28, 110),
      children: [
        Icon(icon, size: 46, color: Colors.white24),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _textDim, height: 1.5),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ),
        ],
      ],
    );
  }
}
