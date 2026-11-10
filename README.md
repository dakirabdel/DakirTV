# Drama Live — simple Flutter client

A minimal client for the Drama Live "FG code" flow:

1. Enter an access code (for example `232425`).
2. Tap **Watch TV**.
3. Pick a topic, then a channel, and it plays.

## How it works

- `lib/api.dart` talks to the same endpoints as the original app.
  Requests are AES/CBC/PKCS5 encrypted and sent as
  `base64(ciphertext):base64(iv)` (key `0123456789abcdef`,
  iv `fedcba9876543210`).
- The flow is:
  - `POST {server_url}activate` with the code
  - `POST {live_url}getliveTopics`
  - `POST {live_url}getLiveByTopic`
  - resolve the stream (`getLiveAllStreamsById`, `getLiveByRedirect`,
    `getLiveByDoubleRedirect`) when needed
- `lib/main.dart` contains the three screens (code, channel list, player).
- Playback uses `video_player` (ExoPlayer on Android), which supports HLS.

## Run

```bash
flutter pub get
flutter run
```

## Build an APK

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Notes

- The API uses plain HTTP, so `android:usesCleartextTraffic="true"` is set
  in `android/app/src/main/AndroidManifest.xml`.
- Some channels use a web-page player (`web-player` / HTML redirect) and are
  not playable by this simple client; they show a "not available" message.
- Only watch content you are authorised to access.
