import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Extracts the video id from a YouTube watch, live, embed or short link.
/// Returns null for anything that is not a YouTube video page.
String? youTubeId(String url) {
  final value = url.trim();
  if (value.isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  final isYouTube = host == 'youtube.com' ||
      host.endsWith('.youtube.com') ||
      host == 'youtu.be' ||
      host.endsWith('.youtu.be');
  if (!isYouTube) return null;

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return null;

  if (host.endsWith('youtu.be')) {
    return _cleanVideoId(segments.first);
  }
  if (segments.first == 'watch') {
    return _cleanVideoId(uri.queryParameters['v']);
  }
  if (segments.first == 'live' ||
      segments.first == 'embed' ||
      segments.first == 'shorts' ||
      segments.first == 'v') {
    return segments.length > 1 ? _cleanVideoId(segments[1]) : null;
  }
  return null;
}

String? _cleanVideoId(String? value) {
  final id = (value ?? '').trim();
  if (id.isEmpty) return null;
  final valid = RegExp(r'^[A-Za-z0-9_-]{6,20}$');
  return valid.hasMatch(id) ? id : null;
}

/// A single error type so the UI can show a friendly message.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Topic {
  Topic({required this.id, required this.name, required this.image});

  final String id;
  final String name;
  final String image;

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: '${json['id_topic'] ?? ''}',
        name: '${json['name_topic'] ?? ''}',
        image: '${json['img_url_topic'] ?? ''}',
      );
}

class Channel {
  Channel({
    required this.id,
    required this.name,
    required this.image,
    required this.url,
    required this.agent,
    required this.backup,
  });

  final String id;
  final String name;
  final String image;
  final String url;
  final String agent;
  final String backup;

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: '${json['id_live'] ?? json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        image: '${json['img_url'] ?? ''}',
        url: '${json['url'] ?? ''}',
        agent: '${json['agent'] ?? ''}',
        backup: '${json['backup'] ?? ''}',
      );

  Channel copyWith({
    String? id,
    String? name,
    String? image,
    String? url,
    String? agent,
    String? backup,
  }) =>
      Channel(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
        url: url ?? this.url,
        agent: agent ?? this.agent,
        backup: backup ?? this.backup,
      );
}

/// One of the playable sources offered by the API for a channel.
///
/// A channel normally has a primary source plus several backups. The web app
/// shows each one as a numbered server chip, so we keep them all here.
class ServerOption {
  ServerOption({
    required this.index,
    required this.label,
    required this.url,
    required this.agent,
  });

  final int index;
  final String label;
  final String url;
  final String agent;

  String get display => label.isEmpty || label == '$index' ? '$index' : '$index · $label';
}

/// A stream URL plus the headers the server wants us to send.
class StreamInfo {
  StreamInfo({
    required this.url,
    this.headers = const {},
    this.format,
    this.label,
  });

  final String url;
  final Map<String, String> headers;

  /// One of `hls`, `dash`, `mp4`, `web`, or null when unknown.
  final String? format;
  final String? label;
}

/// A match returned by the sport endpoint.
class Match {
  Match({
    required this.id,
    required this.title,
    required this.date,
    required this.topic,
    required this.channel,
    required this.url,
    required this.firstTeam,
    required this.secondTeam,
    required this.firstTeamImage,
    required this.secondTeamImage,
    required this.firstTeamScore,
    required this.secondTeamScore,
  });

  final String id;
  final String title;
  final String date;
  final String topic;
  final String channel;
  final String url;
  final String firstTeam;
  final String secondTeam;
  final String firstTeamImage;
  final String secondTeamImage;
  final String firstTeamScore;
  final String secondTeamScore;

  bool get isAvailable => url.trim().isNotEmpty;

  bool get isPlayingNow {
    final lower = date.toLowerCase();
    return lower.contains('playing now') ||
        lower.contains('live now') ||
        date.contains('جارية');
  }

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: '${json['id'] ?? json['title'] ?? ''}',
        title: '${json['title'] ?? ''}',
        date: '${json['date'] ?? ''}',
        topic: '${json['topic'] ?? ''}',
        channel: '${json['channel'] ?? ''}',
        url: '${json['url'] ?? ''}',
        firstTeam: '${json['firstTeam'] ?? ''}',
        secondTeam: '${json['secondtTeam'] ?? json['secondTeam'] ?? ''}',
        firstTeamImage: '${json['firstTeamImage'] ?? ''}',
        secondTeamImage: '${json['secondtTeamImage'] ?? json['secondTeamImage'] ?? ''}',
        firstTeamScore: '${json['firstTeamScore'] ?? ''}',
        secondTeamScore: '${json['secondtTeamScore'] ?? json['secondTeamScore'] ?? ''}',
      );
}

/// Client for the Drama Live "FG code" API.
///
/// Requests and responses are encrypted with AES/CBC/PKCS5 and sent as
/// `base64(ciphertext):base64(iv)`.
class DramaApi {
  static const String serverUrl =
      'http://main.eastgoessouth.online/api/live/livedrama/v13.0.0/';
  static const String liveUrl =
      'http://live.eastgoessouth.online/api/live/livedrama/v13.0.0/';
  static const String redirectUrl =
      'http://redirect.eastgoessouth.online/redirect/';
  static const String sportUrl = 'http://sport.eastgoessouth.online/sport/';

  static const String _keyText = '0123456789abcdef';
  static const String _ivText = 'fedcba9876543210';

  final enc.Encrypter _encrypter = enc.Encrypter(
    enc.AES(enc.Key.fromUtf8(_keyText), mode: enc.AESMode.cbc),
  );
  final enc.IV _iv = enc.IV.fromUtf8(_ivText);
  final String _ivBase64 = base64Encode(utf8.encode(_ivText));

  String deviceId = '';
  String userId = '';
  String? _code;
  bool _initialized = false;

  String? get code => _code;

  /// Loads (or creates) a stable device/user id. Safe to call many times.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getString('device_id') ?? _randomHex(16);
    userId = prefs.getString('user_id') ?? 'fg_${_randomHex(8)}';
    await prefs.setString('device_id', deviceId);
    await prefs.setString('user_id', userId);
    _initialized = true;
  }

  static String _randomHex(int bytes) {
    final random = Random.secure();
    return List.generate(
      bytes,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  String _encrypt(Map<String, dynamic> body) {
    final encrypted = _encrypter.encrypt(jsonEncode(body), iv: _iv);
    return '${encrypted.base64}:$_ivBase64';
  }

  String _decrypt(String payload) {
    final text = payload.trim();
    final separator = text.indexOf(':');
    if (separator < 0) {
      throw ApiException('Invalid server response.');
    }
    final iv = enc.IV.fromBase64(text.substring(separator + 1));
    return _encrypter.decrypt(
      enc.Encrypted.fromBase64(text.substring(0, separator)),
      iv: iv,
    );
  }

  Map<String, dynamic> _base({required bool activated}) => {
        'user_id': userId,
        'device_id': deviceId,
        'device_api': '34',
        'version_name': '13.0.3',
        'language': 'en',
        'timezone': 'UTC',
        'device_type': 'phone',
        'KEY_ACTIVATED_TYPE':
            activated ? (_code ?? 'KEY_ACTIVATED') : 'KEY_ACTIVATED',
        'store': 'none',
        'isStoreVersion': false,
        'isPremium': false,
        'isCoupon_active': false,
        'hideAds': false,
        'appCount': '{"a":0,"b":0,"c":0,"d":0}',
        'mainServer': serverUrl,
      };

  Future<Map<String, dynamic>> _post(
    String base,
    String path,
    Map<String, dynamic> body,
  ) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$base$path'),
            headers: const {'Content-Type': 'application/json; charset=utf-8'},
            body: _encrypt(body),
          )
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      throw ApiException('Could not reach the server. Check your connection.');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(_decrypt(utf8.decode(response.bodyBytes)))
          as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Could not read the server response.');
    }

    final result = json['result'];
    if (result != 0 && result != 1) {
      final message = json['message'];
      throw ApiException(
        message is Map
            ? '${message['en'] ?? message['ar'] ?? 'Request failed'}'
            : 'Request failed',
      );
    }
    return json;
  }

  /// Validates the code with the server and remembers it for the next calls.
  Future<String> activate(String code) async {
    final entered = code.trim();
    if (entered.isEmpty) {
      throw ApiException('Please enter a code.');
    }

    _code = entered;
    final response = await _post(serverUrl, 'activate', {
      ..._base(activated: false),
      'code': entered,
    });

    final data = response['data'];
    final activated = (data is String && data.trim().isNotEmpty)
        ? data.trim()
        : entered;
    _code = activated;
    return activated;
  }

  Future<List<Topic>> topics() async {
    final response = await _post(liveUrl, 'getliveTopics', {
      ..._base(activated: true),
      'type': 'tv',
    });
    return _asList(response['live_topics'])
        .map((e) => Topic.fromJson(e))
        .toList();
  }

  Future<List<Channel>> channels(String topicId) async {
    final response = await _post(liveUrl, 'getLiveByTopic', {
      ..._base(activated: true),
      'type': 'tv',
      'topic': topicId,
    });
    return _asList(response['live'])
        .map((e) => Channel.fromJson(e))
        .toList();
  }

  /// Looks up a set of channels by their ids. Used by the Live tab to turn a
  /// match into a playable channel.
  Future<List<Channel>> channelsByIds(Iterable<String> ids) async {
    final wanted = ids
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (wanted.isEmpty) return const [];

    final response = await _post(liveUrl, 'getLiveById', {
      ..._base(activated: true),
      'id': wanted,
    });
    return _asList(response['live'])
        .map((e) => Channel.fromJson(e))
        .toList();
  }

  /// Today's matches from the sport endpoint.
  Future<List<Match>> matches() async {
    final response = await _post(sportUrl, 'getMatches', {
      ..._base(activated: true),
    });
    return _asList(response['data'])
        .map((e) => Match.fromJson(e))
        .toList();
  }

  Future<Channel> _allStreams(String id) async {
    final response = await _post(liveUrl, 'getLiveAllStreamsById', {
      ..._base(activated: true),
      'id': id,
    });
    final live = response['live'];
    final decoded = live is String ? jsonDecode(live) : live;
    if (decoded is! Map) {
      throw ApiException('No streams found for this channel.');
    }
    return Channel.fromJson(decoded.cast<String, dynamic>());
  }

  /// Returns the full server list (primary + backups) for a channel, with the
  /// same labels the web app shows (SD, HD, 4K, DLW, ...).
  Future<List<ServerOption>> servers(Channel channel) async {
    var live = channel;
    if (live.agent == 'all_streams_redirect' || live.url.trim() == '1') {
      live = await _allStreams(live.id);
    }

    final result = <ServerOption>[];
    final seen = <String>{};

    void add(String rawUrl, String rawAgent) {
      final url = rawUrl.trim();
      final agent = rawAgent.trim();
      if (url.isEmpty) return;
      final key = '$url|$agent';
      if (!seen.add(key)) return;
      final index = result.length + 1;
      result.add(ServerOption(
        index: index,
        label: _serverLabel(url, agent, index),
        url: url,
        agent: agent,
      ));
    }

    add(live.url, live.agent);
    for (final entry in _parseBackup(live.backup)) {
      add(entry.$1, entry.$2);
    }
    return result;
  }

  /// Resolves one server into a playable URL. Returns null when the server
  /// cannot be used (bad payload, offline host, unsupported page, ...).
  Future<StreamInfo?> resolveServer(Channel channel, ServerOption server) async {
    try {
      final info = await _resolveOne(channel.copyWith(
        url: server.url,
        agent: server.agent,
        backup: '',
      ));
      if (info == null) return null;
      return StreamInfo(
        url: info.url,
        headers: info.headers,
        format: info.format ?? _formatFromUrl(info.url),
        label: server.label,
      );
    } catch (_) {
      return null;
    }
  }

  /// Convenience: try the primary server and then the backups until one works.
  Future<StreamInfo?> resolve(Channel channel) async {
    final list = await servers(channel);
    for (final server in list) {
      final info = await resolveServer(channel, server);
      if (info != null && info.format != 'web') return info;
    }
    return null;
  }

  Future<StreamInfo?> _resolveOne(Channel channel) async {
    final url = channel.url.trim();
    final agent = channel.agent.trim();
    if (url.isEmpty || url == '1') return null;

    if (agent == 'all_streams_redirect') {
      final live = await _allStreams(channel.id);
      return _resolveOne(live);
    }

    // `advanced` / `double_redirect` put a JSON object in the url field.
    if (url.startsWith('{')) {
      final Map<String, dynamic> json;
      try {
        json = jsonDecode(url) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }

      final inner = _applySwap('${json['url'] ?? ''}'.trim(), json['swap']);
      final headers = _headersFrom(json);
      final format = _formatFrom(json, inner);

      if (youTubeId(inner) != null) {
        return StreamInfo(url: inner, format: 'youtube');
      }

      if (agent == 'double_redirect') {
        final resolved = await _doubleRedirect(channel.id, url, agent, json);
        if (resolved != null) return resolved;
        if (_isMedia(inner)) {
          return StreamInfo(url: inner, headers: headers, format: format);
        }
        return null;
      }

      if (inner.isEmpty) return null;
      if (agent == 'advanced' || agent.isEmpty) {
        return StreamInfo(
          url: inner,
          headers: headers,
          format: _isWebPage(inner, json) ? 'web' : format,
        );
      }

      // Unknown agent but a usable URL: try it anyway.
      return StreamInfo(url: inner, headers: headers, format: format);
    }

    if (agent == 'redirect' || url.startsWith('http://.LS.V2')) {
      final response = await _post(redirectUrl, 'getLiveByRedirect', {
        ..._base(activated: true),
        'id': channel.id,
        'url': url,
        'agent': agent,
      });
      final data = response['data'];
      if (data is Map && data['url'] is String) {
        return _resolveOne(channel.copyWith(
          url: data['url'] as String,
          agent: '${data['agent'] ?? ''}',
        ));
      }
      if (data is String) {
        return _resolveOne(channel.copyWith(url: data, agent: ''));
      }
      return null;
    }

    if (_isMedia(url)) {
      return StreamInfo(url: url, format: _formatFromUrl(url));
    }

    // A plain http(s) URL that does not look like a media file. Some providers
    // hide an HLS playlist behind an extension-less URL, so let the player try.
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return StreamInfo(url: url);
    }
    return null;
  }

  Future<StreamInfo?> _doubleRedirect(
    String id,
    String rawJson,
    String agent,
    Map<String, dynamic> json,
  ) async {
    final innerUrl = '${json['url'] ?? ''}'.trim();
    if (innerUrl.isEmpty) return null;

    // YouTube pages cannot be handed to a native player: the googlevideo URLs
    // the redirect service returns are bound to the API server and answer 403.
    // Hand the watch URL to the embedded web player instead.
    if (youTubeId(innerUrl) != null) {
      return StreamInfo(url: innerUrl, format: 'youtube');
    }

    final headers = _headersFrom(json);
    final dataBody = '${json['data'] ?? ''}'.trim();

    final http.Response page;
    try {
      if (dataBody.isNotEmpty) {
        page = await http
            .post(
              Uri.parse(innerUrl),
              headers: {
                ...headers,
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: dataBody,
            )
            .timeout(const Duration(seconds: 20));
      } else {
        page = await http
            .get(Uri.parse(innerUrl), headers: headers)
            .timeout(const Duration(seconds: 20));
      }
    } catch (_) {
      return null;
    }

    var rawData = utf8.decode(page.bodyBytes, allowMalformed: true);
    final returnFrom = '${json['returnFrom'] ?? ''}';
    final returnTo = '${json['returnTo'] ?? ''}';
    if (returnFrom.isNotEmpty && returnTo.isNotEmpty) {
      final start = rawData.indexOf(returnFrom);
      final end =
          start < 0 ? -1 : rawData.indexOf(returnTo, start + returnFrom.length);
      if (start >= 0 && end > start) {
        rawData = rawData.substring(start + returnFrom.length, end);
      }
    }
    if (rawData.isEmpty) return null;

    final response = await _post(redirectUrl, 'getLiveByDoubleRedirect', {
      ..._base(activated: true),
      'id': id,
      'url': rawJson,
      'agent': agent,
      'raw_data': rawData,
    });

    final data = response['data'];
    if (data is Map && data['url'] is String) {
      return _resolveOne(Channel(
        id: id,
        name: '',
        image: '',
        url: data['url'] as String,
        agent: '${data['agent'] ?? ''}',
        backup: '',
      ));
    }
    if (data is String) {
      return _resolveOne(Channel(
        id: id,
        name: '',
        image: '',
        url: data,
        agent: 'advanced',
        backup: '',
      ));
    }
    return null;
  }

  Map<String, String> _headersFrom(Map<String, dynamic> json) {
    final headers = <String, String>{};
    final raw = json['headers'];
    if (raw is Map) {
      raw.forEach((key, value) => headers['$key'] = '$value');
    }
    final userAgent = json['agent'];
    if (userAgent is String &&
        userAgent.isNotEmpty &&
        !headers.keys.any((key) => key.toLowerCase() == 'user-agent')) {
      headers['User-Agent'] = userAgent;
    }
    return headers;
  }

  /// Backup entries look like `url -- agent -;- {json} -- agent`.
  List<(String, String)> _parseBackup(String raw) {
    final entries = <(String, String)>[];
    for (final part in raw.split(' -;- ')) {
      final value = part.trim();
      if (value.isEmpty) continue;

      // Keep JSON entries intact: the whole JSON string is the url, and the
      // agent after the last ` -- ` tells us how to resolve it.
      final separator = value.lastIndexOf(' -- ');
      final url =
          separator > 0 ? value.substring(0, separator).trim() : value;
      final agent =
          separator > 0 ? value.substring(separator + 4).trim() : '';

      if (url.isNotEmpty) entries.add((url, agent));
    }
    return entries;
  }

  String _serverLabel(String url, String agent, int index) {
    String? raw;
    if (url.startsWith('{')) {
      try {
        final json = jsonDecode(url);
        if (json is Map) {
          raw = '${json['description'] ?? ''}'.trim();
        }
      } catch (_) {
        // Ignore malformed JSON and fall through to the index.
      }
    } else {
      raw = _between(url, 'description_', '_');
    }
    final label = _cleanLabel(raw);
    return label ?? '$index';
  }

  /// Server descriptions occasionally arrive as placeholder fragments
  /// (e.g. `description_M+_`) or URLs. Keep only short, human labels.
  static String? _cleanLabel(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    const prefix = 'description_';
    if (value.toLowerCase().startsWith(prefix)) {
      value = value.substring(prefix.length);
    }
    while (value.endsWith('_')) {
      value = value.substring(0, value.length - 1).trim();
    }
    value = value.replaceAll('_', ' ').trim();
    if (value.isEmpty || value.length > 16) return null;
    if (value.contains('/') || value.contains('{') || value.contains('}')) {
      return null;
    }
    if (value.toLowerCase() == 'null') return null;
    return value;
  }

  static String? _between(String text, String from, String to) {
    final start = text.indexOf(from);
    if (start < 0) return null;
    final end = text.indexOf(to, start + from.length);
    if (end < 0) return null;
    return text.substring(start + from.length, end);
  }

  static String _applySwap(String url, dynamic swap) {
    if (swap is! Map) return url;
    var result = url;
    swap.forEach((key, value) => result = result.replaceAll('$key', '$value'));
    return result;
  }

  static String? _formatFrom(Map<String, dynamic>? json, String url) {
    final type = '${json?['mediatype'] ?? ''}'.trim().toLowerCase();
    if (type == 'hls' || type == 'm3u8') return 'hls';
    if (type == 'dash' || type == 'mpd') return 'dash';
    if (type == 'mp4' || type == 'video') return 'mp4';
    return _formatFromUrl(url);
  }

  static String? _formatFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8') || lower.contains('/hls/')) return 'hls';
    if (lower.contains('.mpd') || lower.contains('/dash/')) return 'dash';
    if (lower.contains('.mp4') || lower.contains('videoplayback')) return 'mp4';
    return null;
  }

  static bool _isMedia(String url) => _formatFromUrl(url) != null;

  static bool _isWebPage(String url, Map<String, dynamic> json) {
    final type = '${json['mediatype'] ?? ''}'.trim().toLowerCase();
    if (type.isNotEmpty) return false;
    if (_isMedia(url)) return false;
    final lower = url.toLowerCase();
    if (lower.contains('googlevideo.com') ||
        lower.contains('youtube.com') ||
        lower.contains('youtu.be')) {
      return false;
    }
    return true;
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    dynamic decoded = value;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {
        return const [];
      }
    }
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
}
