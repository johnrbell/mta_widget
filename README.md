# MTA Widget

NYC subway status, at a glance. Live at [mtastat.us](https://mtastat.us).

Real-time status for all 23 NYC subway lines via the MTA GTFS-RT alerts feed.

There's also a native iOS app with home-screen widgets in `MTAStatusWidget/`.

## Features

- Real-time status for all 23 NYC subway lines via the [MTA GTFS-RT alerts feed](https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/camsys%2Fsubway-alerts.json)
- Severity-ranked alerts — shows the worst active alert per line
- 5-minute in-memory cache for train data
- PWA-ready — installable on iOS and Android
- Deployed on Vercel

## iOS app

`MTAStatusWidget/` is a standalone SwiftUI app with a WidgetKit extension. It fetches the same MTA feed and displays line status on your home screen via small and medium widgets.

- **Swift 5.9 / SwiftUI / WidgetKit** — iOS 17+
- **XcodeGen** spec in `project.yml` (or use the checked-in `.xcodeproj` directly)
- Shared code in `Shared/` (models, MTA service, alert processing, App Group defaults)

## Setup

### Web

```bash
npm install
npm run dev
```

Runs at [localhost:5173](http://localhost:5173).

Production build:

```bash
npm run build
npm start
```

### iOS

Open `MTAStatusWidget/MTAStatusWidget.xcodeproj` in Xcode, set your development team, and run on a device or simulator. Alternatively, regenerate the project from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

## Stack

- **SvelteKit** (Svelte 5) with `adapter-vercel`
- **MTA GTFS-RT** JSON feed (no key required)
- **Swift / SwiftUI / WidgetKit** — native iOS app and home-screen widgets
