---
name: Driver Velocity
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#3d4a3d'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#6d7b6c'
  outline-variant: '#bccbb9'
  surface-tint: '#006e2e'
  primary: '#006e2e'
  on-primary: '#ffffff'
  primary-container: '#00b14f'
  on-primary-container: '#003a15'
  inverse-primary: '#52e078'
  secondary: '#006d2f'
  on-secondary: '#ffffff'
  secondary-container: '#87fb9d'
  on-secondary-container: '#007433'
  tertiary: '#5f5e5e'
  on-tertiary: '#ffffff'
  tertiary-container: '#9b9999'
  on-tertiary-container: '#323131'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#71fe91'
  primary-fixed-dim: '#52e078'
  on-primary-fixed: '#002109'
  on-primary-fixed-variant: '#005321'
  secondary-fixed: '#87fb9d'
  secondary-fixed-dim: '#6add84'
  on-secondary-fixed: '#002109'
  on-secondary-fixed-variant: '#005322'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1c1b1b'
  on-tertiary-fixed-variant: '#474746'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  display-income:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.03em
  headline-timer:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 22px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-prominent:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  touch-min: 48px
  touch-lg: 56px
  screen-edge: 16px
  card-gap: 12px
  inner-padding: 16px
  pill-padding-x: 14px
  pill-padding-y: 8px
  sheet-bottom-safe: 34px
---

## Brand & Style

The design system serves ride-hailing drivers operating in high-stress, rapid-decision environments on mobile devices mounted at arm’s length. The emotional tone is decisive, reassuring, utilitarian, and empowering. Drivers require absolute visual clarity, instantaneous cognitive processing, and zero friction while in motion. 

The aesthetic is a hybrid of Modern Utility and Tactical Ergonomics:
- **Map-First Focus**: Full-bleed live mapping forms the persistent base layer; UI elements exist as floating, high-contrast modules, bottom sheets, and overlay cards.
- **Arm’s-Length Ergonomics**: Oversized interaction zones (minimum 48–56px touch heights) ensure effortless tapping during stop-and-go transit or road vibrations.
- **Glanceable Metrics**: Vital telemetry—fare earnings, countdown acceptance rings, passenger destination badges—leverage high-weight typography and high-contrast color coding to communicate status in sub-second glances.

## Colors

The palette is tuned for extreme outdoor contrast, bright sunlight legibility, and rapid state identification.

### Key Roles
- **Primary (`#00B14F`)**: Vibrant driver green. Communicates readiness, online state, accept ride actions, and net positive earnings.
- **Primary Dark (`#008F40`)**: Pressed states, active turn indications, and structural visual emphasis on green surfaces.
- **Background (`#F5F7F9`)**: Neutral cool-tinted grey for bottom sheet interiors, sub-cards, and system backdrops without clinical glare.
- **Surface / Pure White (`#FFFFFF`)**: Floating sheet tiles, modal prompts, and bottom sheet containers.
- **Text Primary (`#171717`)**: Near-black for immediate legibility of addresses, fares, and navigation cues.
- **Text Secondary (`#6B7280`)**: Muted slate for metadata, pickup distance, and secondary timestamps.
- **Map Overlay Layer (`rgba(23, 23, 23, 0.82)`)**: Dark translucent obsidian pill treatment behind critical map overlay icons (re-center, layers, traffic toggles) to cleanly isolate controls from chaotic map vectors.

### Semantic Tones
- **Success (`#22C55E`)**: Trip completed, payout success, high passenger rating.
- **Warning (`#F59E0B`)**: Surge pricing heatmaps, short accept-timer alerts, battery conservation notes.
- **Error / Urgent (`#EF4444`)**: Trip decline, cancellation penalties, emergency SOS, and urgent disconnections.

## Typography

Typographic scale is constructed for in-vehicle legibility on a 390x844px canvas. Standard body copy relies on clean tabular numerals where values mutate dynamically (timers, cash amounts, mileage).

- **`display-income`**: Reserved strictly for total earnings and current trip fare numbers. Always set to bold weight (`800`) with tighter tracking for instant peripheral scanning.
- **`headline-timer`**: High-impact numeral format for circular countdown timers when new ride pings hit the screen.
- **`headline-lg` / `headline-md`**: Addresses, rider names, and primary waypoint directives.
- **`label-prominent`**: Used for actionable button labels, slide-to-accept actions, and navigation alerts.
- **Fallback**: System sans-serif (`-apple-system`, `BlinkMacSystemFont`, `Roboto`) to preserve zero-latency font rendering on entry-level Android and iOS driver devices.

## Layout & Spacing

Designed against the standard 390x844px portrait smartphone viewport, the spatial architecture adheres to a strict safe-zone philosophy:

- **Touch Safety Grid**: Primary actionable buttons (Accept, Slide to Arrive, Complete Order) mandate a minimum touch height of `56px` (`touch-lg`) to prevent mis-taps while driving. Secondary toolbar icons must have a hit box of at least `48px` (`touch-min`).
- **Screen Margins**: Global horizontal margin is fixed at `16px` (`screen-edge`). Floating overlays and bottom sheets rest `16px` inset from edges or anchor directly flush with the screen bottom with `34px` bottom home-indicator clearance.
- **Floating Bottom Sheets**: Vertical stacking of 3 states:
  - *Collapsed Mini-Bar (72px)*: Real-time status ("You are online", Daily Earnings).
  - *Trip Incoming Sheet (260–320px)*: Fare breakdown, pickup distance, countdown circle, and acceptance controls.
  - *Turn-by-Turn Extended Sheet (Full bottom half)*: Next maneuver, customer communication shortcuts, and trip itinerary.
- **Spatial Rhythm**: Internal elements within card tiles are spaced in tight 4px/8px intervals (`card-gap` at 12px, `inner-padding` at 16px) to maximize screen area for map visibility.

## Elevation & Depth

Visual hierarchy prioritizes floating context layers above the 2D/3D map plane:

1. **Layer 0 (Base Canvas)**: Full-viewport Vector Map.
2. **Layer 1 (Map Overlays & Telemetry)**: Dark translucent pills (`rgba(23, 23, 23, 0.85)` with `backdrop-filter: blur(12px)`) for GPS status, compass, and layer toggles. Drop shadow: `0 2px 8px rgba(0, 0, 0, 0.18)`.
3. **Layer 2 (Content Cards & Sub-Panels)**: Surface White (`#FFFFFF`) with a subtle 1px border (`#E5E7EB`) and soft ambient ground shadow (`0 4px 16px rgba(0, 0, 0, 0.08)`).
4. **Layer 3 (Modal Alert / Ride Ping Sheet)**: High-prominence surface with deep elevation (`0 12px 32px rgba(0, 0, 0, 0.16)`). Creates unambiguous focus when dispatch offers a new pickup order.
5. **Layer 4 (Safety SOS & Alert Overlays)**: Full-screen scrim with high-contrast alert cards to command unconditional attention.

## Shapes

The design uses balanced, rounded contours that communicate modern digital agility while maximizing touch boundaries.

- **Standard Containers & Bottom Sheets**: `16px` top-corner radius for sliding bottom sheets; `14–16px` continuous radius for floating cards, address preview boxes, and fare breakdowns.
- **Action Buttons & Slide Bars**: `14px` radius for full-width trigger buttons; fully rounded circular `pill-shaped` profiles for status badges, tags, and circular progress indicators.
- **Map Control Floating Action Buttons (FABs)**: Circular (`50%` radius, 48x48px or 52x52px) for instant one-thumb access.
- **Divider & Border Rules**: Crisp, hairline `1px` structural borders (`#E5E7EB` or `#E2E8F0`) to frame cards without visual weight.

## Components

### 1. Buttons & Slide-to-Confirm
- **Primary Accept Button**: Solid `#00B14F` background, `#FFFFFF` text, `56px` height, `14px` corner radius. Contains high-emphasis typography (`label-prominent`).
- **Slide-to-Confirm Bar**: Horizontal track (`#F3F4F6` background, `56px` height) with a draggable high-contrast circular or rounded square handle (`#00B14F` with right arrow icon). Used for irreversible state shifts: "Slide to Arrive", "Slide to Start Trip", "Slide to Complete".
- **Decline / Danger Button**: Ghost or soft red (`#FEF2F2` background, `#EF4444` border/text), `48px` height.

### 2. Status Pills & Badges
- **Driver Online/Offline Switcher**: Pill container with `#00B14F` (Online) or `#6B7280` (Offline). Includes a pulsing live indicator dot.
- **Surge / Multiplier Badge**: High-visibility pill (`#F59E0B` or vibrant orange gradient) with flame/spark icon and bold text (e.g., "+1.5x Surge").
- **Dark Map Overlay Pills**: Jet-black translucent pills with white iconography for quick-action shortcuts (re-center GPS, audio navigation mute, gas station POIs).

### 3. Cards & Sheets
- **Ride Request Card**: High-contrast white card anchored to the bottom. Features an animated countdown ring (`#00B14F` depleting clockwise), prominent fare calculation (`display-income`), passenger pickup distance/ETA, and explicit street name tags with pickup/drop-off route iconography.
- **Earnings Summary Tile**: Modular cards with `#F5F7F9` background, housing tabular driver figures, cash balance, and instant payout buttons.

### 4. Input Fields & Form Elements
- **Search & Destination Inputs**: `52px` field height, white background, `12px` border-radius, crisp `#D1D5DB` borders, with clear map pin prefixes and one-tap clear buttons.
- **Quick-Chat Chips**: Pre-canned reply pills for messaging riders ("I have arrived", "Stuck in traffic") with `36px` height and light-touch outline borders.

### 5. Lists & Route Waypoints
- **Waypoints**: Route nodes connected by vertical step lines. Green circle for pickup point, red square for destination, with bold primary text for address line 1 and muted secondary text for cross-streets and notes.