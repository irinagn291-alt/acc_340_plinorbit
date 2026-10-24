# Orbitglass — Game Specification

**One-line positioning:** Drop a spark-ball through pegs and light every star in each chapter.

| Field | Value |
| --- | --- |
| Product name | Orbitglass |
| Bundle identifier | `com.orbitglass.dome` |
| Domain | https://orbitglass-dome.pro |
| Contact URL | https://orbitglass-dome.pro/contact-us |
| Category | `public.app-category.games` |
| Devices | iPhone (portrait, landscape left, landscape right) and iPad (all orientations) |
| Playfield | portrait, board |
| Interface style | Dark |
| Asset prefix | `ogb_` |

This is a SpriteKit game. Ignore any utility, food, scanner, or catalog rule that conflicts with this document.

---

## 1. Non-negotiable constraints

1. No CocoaPods and no shared code with other apps.
2. English identifiers and player-facing copy.
3. No WebView shell, no remote config, no camera permission.
4. Offline. No wagering, deposits, cash-out, or gambling ads.
5. The playfield is the product. A ledger of marks is a failed build.

---

## 2. Product core

The player taps through a continuous drop and reaches the next chapter. Scene: Planetarium.

Tilting aims the ball and cuts restitution by 20 percent, so the next bounce dies sooner. An untilted bounce still clears a peg. A full tilt can miss the pocket.

### 2.1 User flow

1. Tap the launch lip on Play to release the spark-ball into the pin field
2. Hold to tilt the dome board while the ball rests so the next path aims true
3. Release hold to let the board settle and watch peg hits light stars on the diagram
4. Miss the diagram or land in a dead pocket and restart the run immediately on the same scene
5. Clear all stars in the chapter, advance through four chapters, and chase best score in Records

### 2.2 Essential behaviour

- Portrait SpriteKit playfield filling at least eighty-five percent of the screen at sixty fps
- Tap releases the ball; hold tilts the board and cuts the next bounce restitution by twenty percent
- Five bottom pockets and peg obstacles with a three-star diagram goal per chapter
- Articulated glass-ball hero or named sprite with body, limb, face, and separate shadow plus three parallax layers and foreground weather
- Thin top gauge, chapter mark, and pause glyph only—no bottom Hop button and no labeled rounded rectangles on the field
- Four chapters with immediate fail-and-restart; offline best score and highest chapter in RunRecord
- GameSimulation with fixedSeed clears the opening layout and unit-tests refuse impossible pockets and hold-during-freefall

---

## 3. Uniqueness assignment for Orbitglass

The portfolio axes stay in the table so this app remains unique. The playfield follows the archetype, not a dashboard DNA.

| Axis | Assigned value |
| --- | --- |
| architecture | Drop-board physics loop (DomeScene update at 60 fps; ball restitution 0.72; hold tilt sets board angle and nextBounceRestitution to 0.576 for one contact; five pockets; ChunkSpawner and GameSimulation with fixedSeed refuse layouts where required stars cannot be reached; fail reloads scene; RunRecord stores best chapter and score only) |
| ui | UIKit UITableView NIB registered cells · canvas-first |
| naming | Orbitglass / dome-pin lexicon (DomeScene, SparkBall, PinNode, StarDiagram, BoardTilt, PocketLane, ChapterMark, GameSimulation, RunRecord, RestitutionCut) |
| organization | By dome role (DomeScene, PinField, SparkBall, StarDiagram, BoardTilt, PocketLane, GameSimulation, RunRecord, HUD) |
| dependencies | None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only |
| design | mongodb · instrument-cluster · soft |
| typography | Avenir Next |
| navigation | Dome-locked chrome (the SpriteKit planetarium dome and pin field never leave; Records and Settings arrive as sheets; tap and hold fuse on Play; Pause and Chapter are overlays; no tab bar) |
| art | Claymation claymorphism 3D · tactile |
| twist | Tilt-then-drop (hold aims board and cuts next bounce 20%; hold during freefall refused; fixedSeed refuses dead-pocket chapter layouts) |
| persistence | UserDefaults+Codable · one RunRecord root holding bestScore, highestChapter, and diagramClears, encoded under a single key with debounced save after each run end |
| screens | Play-root planetarium dome (Play is the full-bleed SpriteKit dome, pin field, and diagram; Pause and Chapter are overlays; Records and Settings are sheets; no TabView) |
| scanner | no scanner |
| search_api | none |
| daykey | Int in YYYYMMDD form |
| reference_id | mongodb |
| reference_sha | 8ade6a733fe3d4d264d3ce13dc8720203898c514568f39e9fcd26438c34a2ec7 |

### 3.1 Architecture contract

A SpriteKit scene runs update(currentTime:) at 60 fps for a drop on the board axis. Physics: restitution 0.72, 5 pockets, tilt cuts the next bounce. The chunk spawner reads the current tradeoff and refuses a beat the hero cannot clear. Collision is explicit. Fail restarts the same scene. Best chapter and score persist. Unit tests drive GameSimulation with fixedSeed and never need the view.

### 3.2 UI contract

The playfield fills at least 85 percent of the screen in the archetype orientation. HUD is a thin top gauge, a chapter mark, and a pause glyph. There is no bottom Hop button, no card stack, and no labeled terrain. Touch hits the scene, not a form.

### 3.6 Screen composition contract

One full-bleed playfield. Physical screens: Play, Pause, Chapter, Records, Settings. Review poses of Play, not extra databases: play, aim, bounce, pocket, miss, fail, pause, chapter. Pause and Chapter are overlays. Records is one best-score list. Settings holds contact and reset.

Input: tap releases the ball, hold tilts the board, release lets it fall

---

## 4. Target file organization

```
Orbitglass/
  Orbitglass/
├── App/
│   ├── OrbitglassApp.swift
│   └── RootDomeHostController.swift
├── DomeScene/
│   ├── DomeScene.swift
│   ├── BoardTilt.swift
│   └── RestitutionCut.swift
├── PinField/
│   ├── PinNode.swift
│   ├── ChunkSpawner.swift
│   └── StarDiagram.swift
├── SparkBall/
│   ├── SparkBallNode.swift
│   └── SparkBallShadowNode.swift
├── PocketLane/
│   └── PocketLaneNode.swift
├── GameSimulation/
│   └── GameSimulation.swift
├── RunRecord/
│   ├── RunRecord.swift
│   └── RunRecordStore.swift
└── HUD/
    ├── TopGaugeBarView.swift
    ├── PauseOverlayView.swift
    ├── ChapterOverlayView.swift
    ├── RecordsTableViewController.swift
    ├── RecordRowCell.xib
    └── SettingsSheetViewController.swift
  Assets.xcassets/
```

---

## 5. Screens

Play is one full-bleed `SKScene`. Review poses are frozen moments of that scene: play, aim, bounce, pocket, miss, fail, pause, chapter.
Pause and Chapter are overlays. Records stores the best run. Settings holds reset and the contact link.
Do not invent a screen per mark, gap, or collectible.

---

## 6. Domain model

Publish the physics numbers below as constants and test against them.

Physics: restitution 0.72, 5 pockets, tilt cuts the next bounce.

Runner reach is `runSpeed * (2 * jumpVelocity / gravity) * 0.85`. Heavy jump velocity is `jumpVelocity * (1 - tradeoffDelta)`.
Timing's next window is `max(minWindow, window * (1 - tradeoffDelta))`.
Flight's loaded lift is `lift * (1 - tradeoffDelta)` and must still exceed gravity.
A drop's tilted restitution is `restitution * (1 - tradeoffDelta)`.
The spawner must refuse a beat outside the current envelope. Chapters: 4. Obstacles: peg, dead pocket, narrow gate.

---

## 7. Design system

Direction: archetype `drop`, not the design-axis chrome.

### 7.1 Palette

- `bg` `#1A1420`
- `surface` `#261C2E`
- `ink` `#F6F1E8`
- `accent` `#E07A5F`
- `muted` `#A898A8`
- `sky` `#140E18`
- `far` `#32243C`
- `mid` `#4C3858`
- `ground` `#E6D9C8`
- `hero` `#FFF9F3`
- `hazard` `#D4524A`
- `collectible` `#F2C14E`
- `weather` `#E7DDE8`
- `shadow` `#0C0810`

Read colours from `DesignTokens`. HUD type uses ink on a surface plate. World colours are sky, far, mid, ground, hero, hazard, collectible, weather, and shadow.

### 7.2 Typography

Family: **Avenir Next**

Typography pairs `AvenirNext-Bold` and `AvenirNext-DemiBold` for chapter titles, star counters, and overlay headers with `AvenirNext-Regular` for compact sheet captions and monospaced digits on live score readouts so numeric transitions never jitter during a drop.

### 7.6 Playfield

Full bleed. At least 85 percent of the screen is the scene. Thin top HUD. No bottom control bar. No three equal cards.

---

## 8. Game feel

- Frame loop: dt is 0 on the first frame, then min(currentTime - lastUpdateTime, 1/30). Step GameSimulation with a fixed 1/120 s accumulator. The scene renders that simulation.
- Units stay in px/s^2 and px/s inside GameSimulation. Set physicsWorld.gravity to zero. Physics bodies are for contacts only. Never copy contract gravity into physicsWorld.gravity. SpriteKit uses m/s^2 at 150 points per meter.
- Queue contacts in didBegin and apply them in update.
- Hit-stop is a 40 to 60 ms countdown in update that skips simulation steps. Do not set isPaused or speed to 0 and wait on an action to resume.
- Camera: smoothed look-ahead along the travel axis, plus a decaying trauma shake. No shake when Reduce Motion is on.
- Runner: a 100 ms input buffer and no coyote time. Timing: the contract window is the only leniency. Flight, grid, and drop: squash, a puff, and hit-stop only.
- Runner and flight: a body, a limb on sin(phase), eyes facing velocity, squash through xScale and yScale, and a shadow that shrinks with height. Grid and drop: a named sprite with the same squash.
- One-shot particles, an SKEmitterNode with targetNode set and removed after its lifetime, or pooled puffs. At most 400 live nodes.

The collectible visibly changes the tradeoff. Restart is immediate. The first ten seconds teach the gesture without a paragraph.

---

## 9. Concurrency

Scene updates stay on the main thread. Persistence writes are small and off the per-frame allocator. Do not allocate unbounded nodes inside `update`.

---

## 10. Persistence engineering

`RunRecordStore` encodes a single `RunRecord` Codable struct (`bestScore: Int`, `highestChapter: Int`, `diagramClears: [Int: Int]`, `lastPlayedDayKey: Int`) into `UserDefaults` under key `ogb.runrecord.v1` with a debounced write after each run ends or resets, while `ogb.demo.v1` seeds the initial chapter state on first launch.

Chosen technology: **UserDefaults+Codable · one RunRecord root holding bestScore, highestChapter, and diagramClears, encoded under a single key with debounced save after each run end**

Keep best score and chapter. Provide `resetAllData()` from Settings.

---

## 11. Networking

No required network. Do not add a camera usage string. Do not call a catalog or a food API.

```yaml
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.games
```

---

## 12. Functional twist

Tilting aims the ball and cuts restitution by 20 percent, so the next bounce dies sooner. An untilted bounce still clears a peg. A full tilt can miss the pocket. The opening gesture is enabled on the first frame. An impossible gap, a missed window, or a dead pocket is refused and the run restarts. The Simulator seed opens straight into the play pose with the gesture live. The refused case is an impossible gap, window, or pocket, and the tests reject it.

The twist is visible in play, covered by `GameSimulation`, and described in the README as the reason to retry.

---

## 13. AI-generated assets

Art direction: Stylized drop scene, Planetarium. Flat graphic silhouettes, clear shapes, no letters, no words, no watermark, no UI chrome.

The hero is drawn in code or loaded from a later portrait. These five images are the world kit. Create empty imagesets with these names and load them, with a procedural fallback:

- `ogb_BackdropFar` — Far parallax plate.
- `ogb_BackdropMid` — Mid parallax plate.
- `ogb_Collectible` — Collectible cutout.
- `ogb_PropNear` — Near prop cutout.
- `ogb_PropFar` — Far prop cutout.

BackdropFar and BackdropMid fill the canvas. Collectible, PropNear, and PropFar are solid cutouts with transparent corners. No text in any image.

---

## 14. Demo data

On Simulator only, seed `ogb.demo.v1`, mark onboarding complete, and open the play pose. `-ReviewScreen` then freezes the pose named by the key. Each pose is visually different. Never seed a device.

---

## 16. Anti-patterns

- Labeled tiles: Fresh, Ridge, Packed, Gap, or any word standing in for terrain.
- A bottom Hop or Jump button that plays the game.
- A hero made of one ellipse and one circle.
- A static board that only lerps one column when a button is tapped.
- CRUD screens named after marks.
- A watch-rate, calorie, barcode, or gram feature.
- More than 400 live nodes, or a new node allocated every frame with no pool.
- Contract gravity copied into physicsWorld.gravity.
- A scene created inside body, as SpriteView(scene: SomeScene(...)).
- Hit-stop done by pausing the scene or a node and waiting on an action to resume.

---

## 17. Tests

Add `OrbitglassTests` with a `GameSimulation` type that lives in the app target. The scene steps that type. Tests call it; they do not reimplement the integration.

1. Runs `fixedSeed` and clears the first chunks.
2. Asserts the light or unloaded envelope is `reachable` and the heavy or loaded envelope is stricter.
3. Rejects an impossible gap, window, or pocket.
4. Asserts `nodeBudget` stays at or under 400.
5. Round-trips the best score.
6. Parses `ReviewLaunch.screen`.

---

## 18. README.md

Write what the game is, why the tradeoff is fair, the physics numbers, and how to build it.

---

## 19. Definition of done

- [ ] `xcodegen generate` and the iOS build succeed.
- [ ] Tests pass, including `GameSimulation`.
- [ ] Play, pause, and fail are reachable.
- [ ] The named imagesets are loaded, with a procedural fallback.
- [ ] Contact link is `https://orbitglass-dome.pro/contact-us`.
- [ ] Category is games. No camera key.

---

## 20. Build commands

```bash
cd Orbitglass
xcodegen generate
xcodebuild build-for-testing -scheme Orbitglass -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.orbitglass.dome/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Orbitglass -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.orbitglass.dome/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcodebuild test-without-building -scheme Orbitglass -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.orbitglass.dome/DerivedData'
```

Signing stays off on the command line only. Leave `CODE_SIGN_STYLE: Automatic` in project.yml.
