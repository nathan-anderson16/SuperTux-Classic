# SuperTux Classic
This is the code for the study "Analyzing the Impact of Frametime Spikes on Navigation-Based Tasks in 2D Platformers."

The code for the original SuperTux Classic can be found at https://github.com/Alzter/SuperTux-Classic.

The data analysis code can be found at https://github.com/nathan-anderson16/SuperTux-Analysis.

# Running the Study
The study is played in the browser. The game is exported to HTML5 and hosted on itch.io.

1. Download Godot 3.5.2 from https://godotengine.org/download/archive/3.5.2-stable/
2. Open `SourceCode/project.godot` in Godot. If it's your first time opening it, click "Import".
3. Export with **Project > Export > `laggypengu` (HTML5)**. The preset writes `index.html` (plus its `.js`/`.wasm`/`.pck` files) to `../../Builds/`, relative to `SourceCode/`.
4. Zip the exported files and upload them to itch.io as an HTML game.

Players click **Start Game** on the title screen, which loads the study level (`scenes/levels/isp/isp.tscn`).

# Data Logging (Web Build)
The web build does not produce log files you can collect. All study data is uploaded from the player's browser to two **Google Forms** by [`autoload/OLogger.gd`](SourceCode/autoload/OLogger.gd). Each form is linked to a Google Sheet with two columns:

| Column | Meaning |
|---|---|
| `Timestamp` | When Google received the response, in the spreadsheet's time zone (not the player's). |
| `Number` | The encoded data string described below. |

| Form | Form ID (in the `formResponse` URL) | Sent by |
|---|---|---|
| Event log | `1FAIpQLSc8DQPKc4ifMoBFr8EOz2UL8Op0NdhQMpsa8Pi75OT_q_m0Tg` | `OLogger.send_event_log()` |
| Summary log | `1FAIpQLSf0t2KPbHtLyOQuHfv2lW3xpG2-uq7iIuF5krxu4qYc5nEZbw` | `OLogger.send_summary_log()` |

## When data is sent
Every time the player reaches a checkpoint, a quality-of-experience (QoE) popup asks them to rate the visual smoothness. When they press **Submit** ([`PostRoundPopup.gd`](SourceCode/scenes/menus/PostRoundPopup.gd)), the game:

1. sends **one summary row** for the section they just played,
2. sends **one event row** containing every event since the previous submit, then clears the event buffer,
3. switches to the next lag condition.

So each checkpoint produces one row in each sheet, with (nearly) the same `Timestamp`. Anything that happens after the last submitted checkpoint, or before the player closes the tab, is never sent.

### Player ID
Both rows start with the same player ID: an MD5 hash of a random number (`Scoreboard.player_id`). A new ID is generated each time the page is loaded or refreshed. Use it to group a player's rows across both sheets.

Nothing is reset until the page reloads. If a player finishes and plays again in the same tab, the new rows have the same ID, the cumulative counters keep counting, and the lag rotation continues where it left off.

### Lag conditions
The lag values `[0, 75, 150, 225]` (milliseconds) are shuffled once per page load. The game then cycles through them in that order, moving to the next value after each QoE submit. The study level has 6 checkpoints, so sections 5 and 6 repeat the lag values of sections 1 and 2. For example, the sample data has `225, 75, 150, 0, 225, 75`. The lag value is the length of a single frame freeze (`OS.delay_msec` in [`TuxSM.apply_lag()`](SourceCode/scenes/player/TuxSM.gd)). With lag `0`, no spike happens. The freeze is triggered:
- when Tux **leaves** a lag zone (event `B`) while moving, after a random 10–69 ms delay (`lag_min_delay`/`lag_max_delay` in `isp.tscn`),
- on the first jump after each (re)spawn.

## Summary log format
Example (sample row):
```
6c8d199ff8b5cbae465a1e6ef720ac57_ 187699_0_{}_1870_8_1_11_{}_12.300003_1_5_{0:58.259413,1:2.6,10:2.083333,2:0.7,4:1.683333,5:1.583333,7:1.85,8:1.7}_{1:1,10:1,2:1,4:1,5:1,6:1,7:2,8:1}
```
Split on `_` to get 14 fields:

| # | Field | Example | Meaning |
|---|---|---|---|
| 0 | Player ID | `6c8d…ac57` | See [Player ID](#player-id). |
| 1 | Level timer | ` 187699` | Time left on the level timer at submit, as `SSSmmm` (seconds + milliseconds): `187699` = 187.699 s. The timer counts down from 200 s. The leading space is a `+` sign that Google Forms decodes as a space. |
| 2 | Lag (ms) | `0` | The lag condition for the section just completed: `0`, `75`, `150` or `225`. |
| 3 | Score per zone | `{1:100,6:40}` | `{zone: score gained in that zone}` (coins, enemies, etc.). **Reset on every death.** |
| 4 | Bonus score | `1870` | The HUD "Bonus" value: 10 × whole seconds left on the timer. |
| 5 | Jumps | `8` | Total jump presses since page load (cumulative). |
| 6 | Left presses | `1` | Total left presses since page load (cumulative). |
| 7 | Right presses | `11` | Total right presses since page load (cumulative). |
| 8 | Deaths per zone | `{1:2,4:2}` | `{zone: number of deaths}` since page load (cumulative). |
| 9 | Section time (s) | `12.300003` | Level-timer seconds since the previous QoE submit (the first section is measured from 200 s). **Can be negative** if the level timer was reset in between, e.g. after it ran out. |
| 10 | Checkpoint count | `1` | How many checkpoint QoE popups have been shown since page load. |
| 11 | QoE rating | `5` | The slider value, 1.0 to 5.0 in steps of 0.1 (starts at 3). |
| 12 | Time per zone (s) | `{0:58.26,1:2.6,…}` | `{zone: seconds spent in that zone}` since page load (cumulative). Zone `0` also includes time spent on the title screen and menus. |
| 13 | Zone entries | `{1:1,10:1,…}` | `{zone: number of times entered}` since page load (cumulative). |

Zones are the numbered `Zone N` areas in the level. Zone `0` is the default before Tux enters a numbered zone, and Tux returns to it on every (re)spawn.

## Event log format
Example (start of a sample row):
```
6c8d199ff8b5cbae465a1e6ef720ac57_ 200200Ga000001 199366Hc 199283Ad 199233B 199216A … 187699C
```
The row is the player ID, `_`, then a list of space-separated entries. The spaces are `+` signs that Google decodes as spaces. Each entry is:

```
TIMER  EVENT  STATE  SCORE  ZONE
6 dig  A-K    a-g    4 dig  2 dig
```

The format is **delta-compressed**: after the timer, only the fields that **changed since the previous entry** are written. The first entry of every row is always complete.

| Part | Format | Meaning |
|---|---|---|
| Timer | 6 digits, always present | Time left on the level timer, `SSSmmm` (same as summary field 1). |
| Event | 1 uppercase letter | See the event table. Omitted if it's the same event as the previous entry. |
| State | 1 lowercase letter | Tux's state, see the state table. Omitted if unchanged. |
| Score | 4 digits | The HUD score counter (`????` if over 9999). Omitted if unchanged. |
| Zone | 2 digits | Current zone. Omitted if unchanged. |

To parse an entry, use the regex `^(\d{6})([A-K])?([a-g])?(\d{4})?(\d{2})?$`. After the letters, 6 digits = score + zone, 4 digits = score only, 2 digits = zone only. Fill in each omitted field with its last known value. Examples:

| Entry | Decoded |
|---|---|
| `200200Ga000001` | 200.000 s, `G` right pressed, `a` idle, score 0, zone 1 |
| `199366Hc` | 199.366 s, `H` jump, `c` walking (score/zone unchanged) |
| `196699Ke02` | 196.699 s, `K` jump released, `e` falling, zone 2 |
| `190828Jc002003` | 190.828 s, `J` right released, `c` walking, score 20, zone 3 |
| `03956821` | 39.568 s, same event as previous entry, zone 21 |
| `187699C` | 187.699 s, `C` checkpoint reached (last entry before the QoE popup) |

**Events**

| Code | Event | Logged when |
|---|---|---|
| `A` | `DELAY_ENTER` | Tux enters a lag zone |
| `B` | `DELAY_EXIT` | Tux leaves a lag zone (the spike fires shortly after) |
| `C` | `CHECKPOINT` | A checkpoint is activated |
| `D` | `FINISH` | Tux stops on a reset checkpoint. **Not used:** the study level has no reset checkpoint, so `D` never appears. |
| `E` | `DEATH` | Tux dies. Logged *before* Tux switches to the dead state, so it carries the state Tux was in when he died. |
| `F` | `LEFT` | Left pressed |
| `G` | `RIGHT` | Right pressed |
| `H` | `JUMP` | Tux jumps |
| `I` | `LEFT_RELEASE` | Left released |
| `J` | `RIGHT_RELEASE` | Right released |
| `K` | `JUMP_RELEASE` | Jump released |

**States**

| Code | State |
|---|---|
| `a` | idle |
| `b` | duck |
| `c` | walk |
| `d` | jump |
| `e` | fall |
| `f` | dead |
| `g` | win |

### Caveats when analyzing
- **Repeated events can be lost.** If an event is identical to the previous entry (same event, state, score and zone), nothing changed, so the entry is dropped entirely, timer included.
- **Whole-second timer values are encoded wrongly.** When the time left is a whole number (e.g. exactly 200 s at the start), the millisecond digits are filled with the seconds digits: `200200` means 200.000 s, not 200.200 s.
- **Timer resets.** When the 200 s timer runs out, play continues and entries are logged at `000000`. On the next death, the timer restarts from the value it had at Tux's previous respawn, so it jumps back up. Example from the sample: `… 000000E 000000If 051646Ae00`. This is why the summary's section time can be negative.
- Events are not recorded when Tux doesn't exist (e.g. on menus or the Thank You screen).
- **Uploads are fire-and-forget.** Nothing checks whether Google accepted a row. The event buffer is cleared even if the request failed, or was refused because the previous upload was still in progress, so those events are lost. A very long section could also make the URL too long for Google to accept.
- Totals in the summary (jumps, presses, deaths, time and entries per zone, checkpoint count) are **cumulative for the whole page session**, not per section. Subtract the previous row to get per-section values.

## Other network requests
- **Leaderboard** ([`ThankYou.gd`](SourceCode/scenes/menus/ThankYou.gd)): at the end of the study, if the player clicks **Save Score**, `{datetime, name, score, player_id}` is POSTed as JSON to a Google Apps Script web app (not a Google Form). Nothing is sent if they click "Don't Save". The title screen's **Score Board** button opens a public page (`Global.scoreBoard_url`) that appears to show this leaderboard, so names players type may be publicly visible.
- **IP lookup** ([`TitleScreen.gd`](SourceCode/scenes/menus/TitleScreen.gd)): every title-screen load requests `https://api.ipify.org?format=json`. The result and the browser info gathered in `Global.get_signature()` (user agent, memory, languages, etc.) are only printed to the browser console. **They are not uploaded.**

## Local CSV logs (not used on web)
[`autoload/logger.gd`](SourceCode/autoload/logger.gd) still writes `frame_logs`, `event_logs`, `qoe_logs` and `summary_logs` CSVs to `user://logs`. In the HTML5 build `user://` lives inside the player's browser storage (IndexedDB), so researchers can't access these files. The code that flushes them is also commented out, so they contain only headers. Use the Google Forms data instead.

# Known Issues
- `send_event_log()` and `send_summary_log()` each build a second, unused form URL (`form_url2`). Only the first URL is requested.
- The form data is put in the URL query string without URL encoding. That's why the `+` signs arrive as spaces.
- `OLogger.state_type_map` has no code for Tux's `riding` and `win_inside_igloo` states. An event logged in those states raises an error and is dropped.
- Events after the 6th (last) checkpoint, i.e. the final stretch to the end goal, are never uploaded. Reaching the goal goes straight to the Thank You screen without sending anything.
