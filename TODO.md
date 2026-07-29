# ReelRiot Mobile/Desktop - TODO List

## WatchFreeStreams (wfs.lol) Support

- [ ] **Provider Link Recognition**:
  - Update `StreamLink` model and `Provider` service to parse `wfs` (`WatchFreeStreams`) links returned by `caffeine-api` (`/v1/stream` or `/api/stream`).
  - Flag `wfs.lol` links as `isEmbed: true` / `isM3U8: false`.

- [ ] **WebView Player Integration**:
  - Route `wfs.lol` embed URLs (`https://wfs.lol/embed/movie/{id}`, `https://wfs.lol/embed/tv/{id}/{s}/{e}`) to `InAppWebView` / `WebViewPlayer` instead of native HLS player.
  - Enable JavaScript, DOM Storage, and Fullscreen API support.

- [ ] **Popunder & Ad Blocking**:
  - Inject popup blocking rules / navigation delegation guards in WebView to block external ad redirects when interacting with the embed player.

- [ ] **Source Selection Sheet UI**:
  - Display "WatchFreeStreams" with a distinct provider badge and 1080p quality tag in the stream source selector modal.
