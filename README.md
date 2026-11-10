# DakirTV — Flutter client

A TV-style Flutter client for the Drama Live "FG code" API. It opens with a
splash screen, asks for an access code (default `232425`), then shows a channel
browser and a minimal full-screen player. The same build runs on phones and
Android TV.

> DakirTV is a media player. It does not host or supply any content. Use only
> codes and streams you are authorised to access.

## Screens

1. **Splash** — DakirTV logo and brand while saved settings load.
2. **Code** — pick a saved code or add a new one. `232425` is the default and
   cannot be removed; added codes are persisted. The selection is remembered and
   reused on the next launch.
3. **Home** — topic filters plus a channel grid.
   - Filter order: **Most watched** (`hot_now`), **Bein Sport**, **Morocco**
     (`212`), then every remaining topic.
   - Search filters the current topic by channel name.
   - Pull to refresh, or use **More → Refresh / Switch code**.
4. **Live** — today's fixtures from the sport endpoint, with live matches
   first. Tapping a match resolves its channel and opens the player.
5. **Player** — TV-like and deliberately minimal:
   - Channel name + logo, LIVE badge and a reload button at the top.
   - Server chips directly below the header (usually 4–7 sources).
   - **Next** button after the servers advances to the next source.
   - Channel list is a horizontal strip hidden behind the **Channels** button
     at the bottom; it opens by default only on large screens.
   - Only mute and fullscreen controls are shown.

## Playback behaviour

- **Automatic server switching is always on** and cannot be disabled. A stall
  watchdog checks progress every 5 seconds; if playback stops advancing, the
  player moves to the next server automatically.
- Selecting a server, pressing **Next**, or a failed load all retry
  automatically. If every server fails, a friendly error is shown.
- Supported formats: HLS (`.m3u8`), DASH (`.mpd`), progressive MP4, plus
  server-provided headers. The API's `mediatype` hint is passed to
  `video_player` so HLS is detected reliably.
- YouTube-backed channels are not played by `video_player` (googlevideo URLs
  return 403). They open in an embedded WebView at
  `https://m.youtube.com/watch?v=<id>` with a Chrome mobile user agent.

## Responsive layout / Android TV

- Breakpoint at **840 dp**: wide screens get a larger header, 46 dp server
  chips and 128 dp channel tiles; phones use a compact layout.
- The player channel rail opens by default when width ≥ 840 dp **and**
  height ≥ 620 dp, so the video keeps enough room.
- D-pad/focus friendly: server chips, **Next**, **Channels** and channel tiles
  are focusable with focus highlights and tooltips.
- Android TV: `LEANBACK_LAUNCHER` intent filter, `android.software.leanback`
  optional, touchscreen not required, and a 320×180 banner at
  `android/app/src/main/res/drawable/banner.png`.
- Package: `com.dakirtv.app` (installs alongside the original app).

## Project structure

| Path | Purpose |
|---|---|
| `lib/main.dart` | App shell, theme, splash, code, home, live and player screens |
| `lib/api.dart` | AES transport, API client, models, stream/server resolution |
| `assets/icons/` | Launcher/splash logo (`icon_foreground.png`, `icon_background.png`) |
| `test/widget_test.dart` | Splash brand smoke test |
| `android/app/src/main/AndroidManifest.xml` | DakirTV label, TV support, cleartext HTTP |

### API client

`lib/api.dart` talks to the same endpoints as the original app. Request bodies
are AES/CBC/PKCS5 encrypted and sent as `base64(ciphertext):base64(iv)`
(key `0123456789abcdef`, iv `fedcba9876543210`). Responses are decrypted the
same way.

Endpoints:

| Host | Endpoint | Used for |
|---|---|---|
| `main…/api/live/livedrama/v13.0.0/` | `activate` | Validate an access code |
| `live…/api/live/livedrama/v13.0.0/` | `getliveTopics` | Home filters |
| `live…/api/live/livedrama/v13.0.0/` | `getLiveByTopic` | Channels for a filter |
| `live…/api/live/livedrama/v13.0.0/` | `getLiveById` | Resolve channels by id (Live tab) |
| `live…/api/live/livedrama/v13.0.0/` | `getLiveAllStreamsById` | Primary + backup servers |
| `redirect…/redirect/` | `getLiveByRedirect` | Redirect-style streams |
| `redirect…/redirect/` | `getLiveByDoubleRedirect` | Double-redirect streams |
| `sport…/sport/` | `getMatches` | Live tab fixtures |

Channels whose `agent` is `all_streams_redirect` (and `url` is `1`) are first
expanded through `getLiveAllStreamsById`. Backup sources are parsed from the
channel's `backup` field, and server labels are cleaned from placeholders such
as `description_M+_` → `M+`; unreadable labels fall back to the server number.

## Requirements

- Flutter SDK (Dart `^3.11.1`)
- Android SDK; the app targets the Flutter default SDK levels
- Main dependencies: `video_player`, `webview_flutter`, `webview_flutter_android`,
  `http`, `encrypt`, `shared_preferences`
- Dev: `flutter_launcher_icons` (regenerate icons with
  `dart run flutter_launcher_icons`)

## Run

```bash
cd flutter/app
flutter pub get
flutter run
```

## Test

```bash
flutter analyze
flutter test
```

## Build and install

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell am start -n com.dakirtv.app/com.example.app.MainActivity
```

## Notes and limitations

- The API is plain HTTP, so `android:usesCleartextTraffic="true"` is set in the
  manifest.
- Some sources are web pages or unsupported embeds; the player reports them as
  unavailable and continues to the next server.
- The backend serves third-party TV content. This client only provides a player
  UI; modify or redistribute only with the necessary authorisation.
