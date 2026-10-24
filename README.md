# Orbitglass

Drop a glass spark through a planetarium dome and light every star.

Tilt is the aim and the cost. Holding the board slides the spark and cuts the next bounce from 0.72 to 0.576, so that bounce dies 20 percent sooner. An untilted drop still clears a peg and finds the center pocket. A full tilt can carry the spark into a dead pocket. Hold during freefall is ignored. That is the reason to retry: aim only while the spark is waiting, and do not spend the bounce unless the pocket is worth it.

## Physics

- Restitution `0.72`
- Tilted next bounce `0.576` for one contact
- Five pockets
- Four chapters
- Gravity lives in the simulation at 1600 px/s^2. The SpriteKit world gravity stays zero.

`ChunkSpawner` refuses a layout when the peg gap, the timing window, or the pocket is outside that envelope. `GameSimulation` with `fixedSeed` clears the opening chunks.

## Play

Tap releases the spark. Hold tilts the board. Release lets it fall. Miss a star or land in a dead pocket and the same dome reloads. Pause and chapter sit on top of the dome. Records keeps the best score and chapter. Settings resets that record and opens contact.

## Build

```bash
cd apps/Orbitglass
xcodegen generate
xcodebuild build-for-testing -scheme Orbitglass -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```

Signing stays automatic in the project. Turn it off only on the command line.
