<!-- gf-brief source=cb08f342232c315ead2c9c105242375499a812f72658850060c2df1cef009ff5 written=2026-10-24T21:40:17+03:00 -->
# Plinorbit

## What it is
Plinorbit is a one-screen physics drop game. A glass piece falls through pins toward pockets; the player tilts the board, lights stars, and tries to land in an open pocket. It is for someone who wants a short, repeatable aim-and-drop session. Nothing is wagered.

## Launch and onboarding
A cold launch opens straight onto the playfield in a dark full-screen view. There is no title screen, sign-in, or first-run card.

The top bar shows the chapter as "01", the score as "0", a pause control (two vertical bars; VoiceOver name "Pause"), a thin progress track, and the line "Light every star. Tap drops, hold aims." The glass rests at the top of a pin field. Stars sit on the board. Five pockets line the bottom.

A chapter card is not shown for chapter 1. It appears only after the player has cleared enough pockets to enter a later chapter. The board freezes under the card until "Continue" is tapped.

## Screens

### Playfield
There are no tabs. The only main screen is the dome.

On it: the falling glass, pins, stars that dim once collected, and five bottom pockets. The two outer pockets are marked as hazards. The top bar shows the chapter number ("01" through "04"), the current run score, the progress of lit stars, the line "Light every star. Tap drops, hold aims.", and the pause control.

Touching the board tilts it toward the finger. Releasing the touch, including a short tap, lets the glass go. While it is falling, another hold does not aim or drop again. Each lit star adds 10 to the score. Landing in an open pocket after every star is lit adds 25, parks the glass at the top, and loads the next drop. Two successful pockets advance the chapter, up to "04".

The pause control freezes the drop and opens the pause overlay.

### Paused
Title "Paused". Caption "The dome holds."

- "Resume" hides the overlay and continues the same drop.
- "Records" opens the Records sheet. The drop stays paused underneath.
- "Settings" opens the Settings sheet. The drop stays paused underneath.

### Chapter card
Shown over the frozen board when the chapter advances. One "Continue" button hides the card and resumes the drop.

Chapter 2 is titled "Warm Pins". The line under it is "A full tilt can miss the pocket. Keep the board level when the lane is open."

Chapter 3 is titled "Pale Weather". The line under it is "An untilted bounce still clears a peg. Spend the tilt only to steer."

Chapter 4 is titled "Last Pocket". The line under it is "Light every star, then take the center pocket."

A chapter 1 card titled "Glass Lip", with the line "Tap releases the glass. Hold aims, and the next bounce dies sooner.", is not shown on a normal launch.

### Records
Sheet title "Records". "Close" dismisses it. A grabber lets the sheet sit at half height or full height.

The list is always six rows:

- "Best score" and a number
- "Highest chapter" and a number
- "Chapter 1 clears" and a number
- "Chapter 2 clears" and a number
- "Chapter 3 clears" and a number
- "Chapter 4 clears" and a number

Before any finished drop, those numbers read 0, 1, 0, 0, 0, and 0. Rows are not tappable.

### Settings
Sheet title "Settings". "Close" dismisses it. Same half-height or full-height sheet.

On the sheet: the word "ORBITGLASS", the heading "On this device", and the line "Best score and chapter stay here. Nothing is wagered."

- "Contact" opens the support page in the browser.
- "Reset" clears the saved best score, highest chapter, and chapter clear counts, then shows "Scores cleared." There is no confirmation.

## Features
- Drop the glass with a tap, or hold to tilt the board before release.
- A tilted release makes the next bounce die sooner.
- Light stars on the way down. The top track fills as they light.
- Land in an open pocket only after every star is lit.
- Four chapters, shown as "01" to "04", with a card and "Continue" between them.
- A run score on the playfield, and saved "Best score", "Highest chapter", and "Chapter 1 clears" through "Chapter 4 clears".
- Pause, then "Resume", "Records", or "Settings".
- "Reset" on the device, with "Scores cleared."
- "Contact" for the support page.
- Glass tones on release, bounce, a lit star, a failed drop, and a new chapter. A light tap accompanies a lit star.

## Behaviours that can look like bugs
- A hold while the glass is already falling does nothing. Wait until it rests at the top, then tap or hold again.
- Landing in an outer pocket, or in an open pocket before every star is lit, ends the run with no alert. The board returns to "01" and the score returns to "0". "Best score" and "Highest chapter" stay as they were.
- Two open-pocket landings are required before the next chapter card appears. Further landings after "04" stay on "04".
- "Continue" and "Resume" are the only ways back into a frozen drop. The board does not move under those overlays.
- "Reset" asks for no confirmation. It clears the Records numbers and shows "Scores cleared." The drop already on screen keeps its current score until that drop ends.
- Records always shows the six rows, including zeros. There is no separate empty-state sentence to dismiss.
- A new launch always starts at "01" with score "0", even when "Highest chapter" in Records is higher.

## Starter content and resume
None. No sample scores or sample runs are placed on the device. An unfinished drop is not restored. Only "Best score", "Highest chapter", and the four chapter clear counts remain.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content, an account deletion flow, and an App Tracking Transparency prompt are all absent.

## Data and support
Best score, highest chapter, and chapter clear counts stay on this device. Settings says "Best score and chapter stay here. Nothing is wagered." "Contact" on Settings opens the support page. "Reset" wipes those saved numbers on the device.

## Scanning and health
None.

## Platform
No region-specific screens or copy. The interface is English and dark. iPhone uses portrait and both landscapes. iPad uses portrait, upside-down portrait, and both landscapes. The app is full screen on iPhone and iPad. Minimum iOS version is 17.0.

## Category
Games — Puzzle.
