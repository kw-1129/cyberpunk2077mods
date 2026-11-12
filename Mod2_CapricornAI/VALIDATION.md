# Final validation — 2026-11-12

## Subsequent installed chat update

- Added a compact native Codeware popup with text input, send/close buttons and quick interactions; no CET overlay required during chat.
- F10 toggles chat. Esc closes it. New `cr_chat_window` CET binding is independent of offline greeting.
- Updated three-mod REDscript compilation succeeded. Lua harness passed hotkey toggle, native input dispatch, busy reset and CET-overlay isolation.
- No game was started for these checks. In-game rendering is not claimed as verified; restart is required for the new REDscript class.
- Final installable payloads retained as desktop folders; duplicate ZIP files and development caches removed.

## Delivered scope

- Mod1: Chimera command platform; custom Basilisk excluded from active package.
- Mod2: downloaded Capricorn base plus separate API/offline interaction extension.
- Basilisk now uses the independent Mod3 package; obsolete backup was removed.
- Nexus 16138 download/installation cancelled by user.

## Checks completed

1. REDscript 0.5.32 compilation against the installed Cyberpunk 2077 2.5 original script bundle, Codeware, ArchiveXL, Audioware and Mod Settings: success. The compiler emits one existing Codeware Reflection.Call return-path warning.
2. LuaJIT syntax for all four Lua files: success.
3. Offline Lua harness: dialogue, healing, short-circuit routing and Chimera follow/guard/stop/deploy dispatch: success.
4. Portable Python AI bridge: five tests passed, including real HTTP against a local compatible test server, action allowlist, disabled actions, plaintext fallback, endpoint validation and redacted API errors.
5. Each desktop package payload and ZIP entry checked against SHA256 manifest; ZIP CRC test passed.
6. Both installers run sequentially against a temporary fixture. Shared dependencies reused, existing CET config preserved, original executable sentinel preserved, uninstall removes mod code while preserving shared dependencies: success.
7. Original game script bundle SHA256 unchanged: `b78043064ae90fb80861b0d885d1c8dbcd22070f1db71f20664d19f2d83c4aac`.

## Earlier isolated in-game evidence

- Basilisk generated, driver seat mounted, movement response about 16 m. Superseded implementation retained as requested backup.
- Actual Chimera NPC generated and intact in an already-completed-quest save.
- Native move command traversed 15 m.
- Native combat targeting killed an isolated spawned test enemy (health 310.75 -> 0).
- Native Chimera health observed: 17335.199 in the test save.
- Both mod families loaded together and game-side compilation succeeded before the user's request to stop game operation.

## Not claimed as verified

- Final command-mode guard/follow/stop lifecycle, vehicle firing, final health/phase transition behavior have not all been rerun in game after the user's stop instruction.
- Final simplified Capricorn UI was not rerun in game after the stop instruction.
- A real paid AI endpoint was not called; no user API key was available.
- The ModDB Capricorn uploader is not the same account name as the Nexus author. Exact parity with Nexus 36701 version 1.2 is not established. Source provenance is included in the package.

## Original installation

Only an isolated workshop runtime was used for earlier execution. Original game archives and original script bundle were not overwritten. The three compatible mods were subsequently installed into the Steam directory at the user's request.

## Language and English filenames update

Controls follow the game interface language: zh-cn, zh-tw, with English fallback. All package paths are ASCII English. Combined REDscript compilation and locale UI/command harness passed. Chimera also compiles independently without Capricorn. AI language propagation passed local HTTP tests. The game was not launched for this update.
