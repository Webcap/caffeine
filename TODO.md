# ReelRiot Mobile - Project Task Backlog

**Document Identification:** RR-TODO-2026-08  
**Standard Compliance:** IEC/IEEE 82079-1:2019 (*Information for use of products — Structure, Content and Presentation*)  
**Project:** ReelRiot Mobile (`c:\Users\cnieves.wmg\Desktop\Projects\reelriot`)  
**Status:** Active  

---

## 1. Backlog & Pending Enhancements

### 1.1. Telemetry, Compliance & Privacy
* [ ] Update Privacy Policy documentation and in-app disclosure to reflect app version telemetry data collection (`client_version`, `platform`, `environment`, `device_id`, `event_type` for version checks, update prompts, and download interactions).
* [ ] Add automated telemetry/QoS event verification for embedded player streams.
* [ ] Implement playback buffering and bit-rate health telemetry logging.

### 1.2. Offline & Sync Optimization
* [ ] Optimize background synchronization for multi-device bookmark updates.

### 1.3. UI & Feature Deprecation / Cleanup
* [ ] Remove "Check Server" status page (`lib/screens/common/server_status_screen.dart`) and its corresponding entry point in profile tab preferences.

### 1.4. Security & Authentication
* [ ] **Password Hardening & Entropy Validation:** Enforce advanced client-side password strength requirements (minimum 12 characters, uppercase/lowercase/numbers/symbols complexity validation, and sequential character rejection) in `register_screen.dart` and `password_change.dart`.
