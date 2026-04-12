# MTA Widget

NYC subway status — with personality. Live at [mtastat.us](https://mtastat.us).

Every five minutes, a cron job checks the MTA feed. When something changes, Google Gemini writes a social-media post as that train line — fully in character. The result is a living feed of 23 opinionated subway trains reacting to their own service status in real time.

The classic at-a-glance status board is still available at [mtastat.us/ez](https://mtastat.us/ez).

There's also a native iOS app with home-screen widgets in `MTAStatusWidget/`.

## How it works

1. **GitHub Actions** hits `POST /api/poll` every 5 minutes
2. The poll endpoint fetches the MTA GTFS-RT alerts feed, diffs against the last known state in Supabase, and skips lines with unchanged status (unless a 24-hour heartbeat is due)
3. For each changed line, **Gemini** generates a 280-character post using the line's persona and recent history
4. Posts are written to Supabase and rendered on the home page as a social feed with story-style line bubbles

## Web app

| Route | What it does |
|---|---|
| `/` | Social feed — AI-generated posts from every train line |
| `/ez` | Classic status board — live MTA status for all 23 lines, tap to expand alerts |

Both views share the same background system: solid black, random NYC photo (Unsplash), or animated subway map canvas. Toggle in the footer.

PWA-ready — installable on iOS and Android. Launches full-screen, no browser chrome.

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

### Environment variables

| Variable | Required | Description |
|---|---|---|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Yes | Supabase service-role key (server-side only) |
| `GEMINI_API_KEY` | Yes | Google Generative AI key for post generation |
| `CRON_SECRET` | Yes | Shared secret between GitHub Actions and `/api/poll` |
| `UNSPLASH_ACCESS_KEY` | No | Enables random NYC background photos; without it a default set is used |

### GitHub Actions

`.github/workflows/poll.yml` runs on a 5-minute cron schedule. It requires two repository secrets:

- `POLL_URL` — the full URL to your deployed `/api/poll` endpoint
- `CRON_SECRET` — must match the value set in your Vercel environment

## Stack

- **SvelteKit** (Svelte 5) with `adapter-vercel`
- **Supabase** — social feed storage, status log deduplication
- **Google Gemini** — in-character post generation
- **MTA GTFS-RT** JSON feed (no key required)
- **Unsplash API** — background images
- **GitHub Actions** — 5-minute poll cron
- **Swift / SwiftUI / WidgetKit** — native iOS app and home-screen widgets
