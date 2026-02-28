## When you resume the app from recents

1. **Lifecycle**  
   Flutter calls `didChangeAppLifecycleState(AppLifecycleState.resumed)` because the screen uses `WidgetsBindingObserver` (registered in `initState` ~502, removed in dispose ~4402).

2. **Resume handler**  
   That calls `_handleAppResumed()` (~773).

3. **Immediate cleanup**  
   - Clear snackbars, round overlays (`_announcementManager.clearSequence()`), and stop phase media.  
   - Optional delayed cleanups (post-frame, 100 ms, 500 ms, 1 s) repeat snackbar/media clear so nothing from “past” state sticks.

4. **Skip if game ended**  
   If `_isGameEnded`, we skip room check and return (user is on ad/leaderboard).

5. **Show “resuming”**  
   `setState(() => _isResuming = true)` and a 12 s safeguard that turns off the loading if something hangs.

6. **Socket still connected**  
   After 200 ms delay, if socket is connected we wait 300 ms and call `_joinRoomIfNotRecent()` so the server knows we’re back (no new socket; same one reconnects if needed; `setOnReconnect` also re-joins and `room_joined` carries phase).

7. **Fetch room state (source of truth)**  
   We call `_roomRepository.getRoomDetails(roomId)` with a 6 s timeout.  
   - **Failure**: If error is 404/“not found”, we retry once; if still 404 we call `_showAdAndExit()`. For other errors we stay in the room and rely on the socket.  
   - **Success**: We apply room to state: `_room`, `_currentPhase`, `_phaseTimeRemaining`, and **drawer sync** (`_isDrawer` from `room.currentDrawerId`; if not drawer we clear `_wordOptions`, `_isWordSelectionDialogVisible`, `_currentDrawerInfo`). We clear round overlays and, if not drawer, cancel word-selection countdown. If room is closed/inactive we schedule `_showAdAndExit()`. If room is playing we call `_syncWithPlayingRoom()` (timer from `roundPhaseEndTime` + `request_canvas_data`).

8. **Timeout / exception**  
   On exception or timeout we clear `_isResuming` and, if still playing, emit `request_canvas_data` so we can catch up later.

So: **resume = cleanup UI/media → show resuming → re-join if socket up → getRoomDetails → apply room (phase, drawer, overlays) → if playing, sync timer and request canvas.**

---

## Markdown file for your repo

Save this as something like **`docs/APP_RESUME_FLOW.md`** (or `RESUME_FLOW.md` in the project root). It’s a **.md** file, not .md5.

```markdown
# App resume flow (Game Room)

What happens when the user brings the app back from recents while on the Game Room screen.

## Entry point

- **Class:** `GameRoomScreen` (e.g. `game_room_screen.dart`).
- **Mixin:** `WidgetsBindingObserver` (line ~208).
- **Registration:** `WidgetsBinding.instance.addObserver(this)` in `initState` (~502); `removeObserver(this)` in `dispose` (~4402).

When the app goes to background and then user reopens from recents, Flutter calls:

```dart
void didChangeAppLifecycleState(AppLifecycleState state)
```

- `state == AppLifecycleState.resumed` → `_handleAppResumed()`.
- `state == paused/inactive` → stop phase media and cancel smooth progress timer (timer is restarted after server sync on resume).
- `state == detached` → emit "prepare to leave permanently" and stop phase media.

---

## Resume flow (`_handleAppResumed`, ~773)

### 1. Guards and immediate cleanup

- If `!mounted` → return.
- Clear UI/sound from past state:
  - `ScaffoldMessenger.of(context).clearSnackBars()`
  - `_announcementManager.clearSequence()` — removes any round overlays (ToughRound / CloseCall / PerfectRound)
  - `_stopAllPhaseMedia()` — pause interval, who's next, timeup, etc.
- Extra cleanup at post-frame, 100 ms, 500 ms, 1 s (snackbars + media again) so nothing sticks.

### 2. Skip if game ended

- If `_isGameEnded` → log and return (user is on ad/leaderboard; no room check).

### 3. Show “resuming” and safeguard

- `setState(() => _isResuming = true)` so UI can show a loading/resuming state.
- After 12 s, if still `_isResuming`, clear it so the user never stays stuck.

### 4. Short delay then socket / join

- `await Future.delayed(200 ms)`.
- If `_socketService.socket?.connected == true`:
  - Wait 300 ms, then `_joinRoomIfNotRecent()` so server knows we’re back.
- No new socket on resume; if socket had disconnected, the same instance auto-reconnects and `setOnReconnect` triggers a re-join; `room_joined` carries current phase.

### 5. Fetch room state (source of truth)

- `_roomRepository.getRoomDetails(roomId: widget.roomId)` with **6 s timeout**.

**On failure (fold left):**

- Log error.
- If error is 404 / "not found": retry `getRoomDetails` once (8 s timeout).
  - Retry still 404 → `setState(_isResuming = false)` and `_showAdAndExit()`.
  - Retry success → update `_room`, clear `_isResuming`; if playing, emit `request_canvas_data`.
- Non-404 → clear `_isResuming`, stay in room; if playing, emit `request_canvas_data` and rely on socket.

**On success (fold right, room found):**

- **setState:**
  - `_room = room`, `_waitingForPlayers` from status.
  - Lobby/waiting → reset game-ended flags and waiting state.
  - Closed/inactive → set waiting and game-ended flags.
  - **If playing and roundPhase set:**
    - `_currentPhase`, `_phaseTimeRemaining`, `_waitingForPlayers = false`.
    - **Drawer sync:** `_isDrawer` from `room.currentDrawerId` (same logic as `room_joined`).
    - If **not** drawer: `_wordOptions = null`, `_isWordSelectionDialogVisible = false`, `_currentDrawerInfo = null`.
- **After setState (playing only):**
  - `_announcementManager.clearSequence()` again (all phases, including reveal).
  - If not drawer: `_cancelWordSelectionCountdown()`.
- If room **closed/inactive** → schedule `_showAdAndExit()` and return.
- If room **playing** → `_syncWithPlayingRoom()`.

### 6. `_syncWithPlayingRoom()` (~9240)

- Guard: mounted, room status playing, room code not null.
- setState: `_waitingForPlayers = false`, `_currentPhase` from room, `_phaseTimeRemaining` from `_remainingSecondsFromRoom(room)`.
- If `room.roundPhaseEndTime` set: start 1 s periodic timer and smooth progress timer from that end time.
- If no end time but `_phaseMaxTime > 0`: update progress animation from current remaining.
- Emit `request_canvas_data` with `roomCode` so server (or drawer client) can send back strokes + room so UI matches.

### 7. Exception path

- On any exception in the try block: log, clear `_isResuming`, and if room is playing emit `request_canvas_data`.

---

## Summary diagram

```
User reopens app from recents
    → didChangeAppLifecycleState(resumed)
    → _handleAppResumed()
        → Clear snackbars, overlays, media (and delayed repeats)
        → If _isGameEnded → return
        → _isResuming = true (+ 12s safeguard)
        → 200ms delay
        → If socket connected → 300ms → _joinRoomIfNotRecent()
        → getRoomDetails(roomId) [6s timeout]
            → Failure → 404? retry once → exit or stay + request_canvas_data
            → Success → setState(room, phase, drawer, clear drawer state if guesser)
                      → clear overlays; if not drawer cancel word selection
                      → if playing: _syncWithPlayingRoom() (timer + request_canvas_data)
        → On exception: clear _isResuming, request_canvas_data if playing
```

---

## Related code locations (approx. line numbers)

| What | Where |
|------|--------|
| Lifecycle callback | ~757 `didChangeAppLifecycleState` |
| Resume handler | ~773 `_handleAppResumed` |
| getRoomDetails success (room state + drawer + overlay) | ~959–1004 |
| getRoomDetails failure / retry | ~862–955 |
| _joinRoomIfNotRecent | ~1328 |
| _syncWithPlayingRoom | ~9240 |
| Observer add/remove | ~502 initState, ~4402 dispose |
```