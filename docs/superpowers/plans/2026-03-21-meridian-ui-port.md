# Meridian UI Port: Rust/GTK4 → Swift/PineUI

> **Status:** Plan only — not yet started. Save for a dedicated session.

**Goal:** Rewrite Meridian's GTK frontend in Swift/PineUI while keeping the Rust daemon backend. Communicate via the existing Unix socket JSON-RPC protocol.

**Why:** Proves PineUI works as a real app framework, not just a demo.

---

## Current Architecture

```
┌─────────────────┐     Unix Socket     ┌──────────────────┐
│  meridian-gtk    │ ◄──── JSON-RPC ───► │  meridian-daemon  │
│  (Rust/GTK4)     │                     │  (Rust)           │
│  35 files, 8.4K  │                     │  DB, sync, AI     │
│  lines           │                     │                    │
└─────────────────┘                     └──────────────────┘
```

**Target:**
```
┌─────────────────┐     Unix Socket     ┌──────────────────┐
│  meridian-swift  │ ◄──── JSON-RPC ───► │  meridian-daemon  │
│  (Swift/PineUI)  │                     │  (Rust)           │
│  ~20 views       │                     │  (unchanged)      │
└─────────────────┘                     └──────────────────┘
```

## Views to Port (20)

| # | View | Rust File | Complexity | Notes |
|---|------|-----------|-----------|-------|
| 1 | Dashboard | dashboard.rs | High | Charts, summary cards, morning briefing |
| 2 | FluidTime | fluidtime.rs | High | Time tracking, schedule display |
| 3 | Tasks/Kanban | kanban.rs | High | Drag-and-drop kanban board |
| 4 | Standup | standup.rs | Medium | Standup notes form |
| 5 | Email | email.rs | Medium | Email list + compose |
| 6 | Meetings | meetings.rs | Medium | Calendar/meeting list |
| 7 | Code Review | review.rs | Medium | PR list with health indicators |
| 8 | Career | career.rs | Medium | Skills, goals, growth tracking |
| 9 | Invoices | invoice.rs | High | Invoice generation, PDF export |
| 10 | Focus | focus.rs | Low | Focus timer/pomodoro |
| 11 | Wellness | wellness.rs | Low | Wellness tracking |
| 12 | Blockers | blockers.rs | Low | Blocker list |
| 13 | Decisions | decisions.rs | Low | Decision log |
| 14 | Releases | releases.rs | Low | Release tracking |
| 15 | Settings | settings.rs | Low | App settings form |
| 16 | Profile | profile.rs | Low | User profile |
| 17 | Chat | chat.rs | High | AI chat panel (streaming) |
| 18 | Onboarding | onboarding.rs | Low | First-run wizard |
| 19 | Context Switcher | context_switcher.rs | Medium | Multi-client context |
| 20 | App Shell | app.rs | High | Nav rail, content stack, chat pane |

## Implementation Order

### Phase 1: Foundation
1. Create Swift package `meridian-swift` (or add executable target to PineUI)
2. Implement JSON-RPC IPC client in Swift (Unix socket, async)
3. Build app shell: nav rail, content stack, status bar
4. Dashboard view (proves the full pipeline works)

### Phase 2: Simple Views (Low complexity)
5. Settings
6. Focus
7. Wellness
8. Blockers
9. Decisions
10. Releases
11. Profile
12. Onboarding

### Phase 3: Medium Views
13. Standup
14. Email
15. Meetings
16. Code Review
17. Career
18. Context Switcher

### Phase 4: Complex Views
19. FluidTime
20. Kanban (needs drag-and-drop)
21. Invoices (needs PDF generation)
22. Chat (needs streaming IPC)

## IPC Protocol

The Rust daemon exposes JSON-RPC 2.0 over Unix socket at `$XDG_RUNTIME_DIR/meridian/daemon.sock`.

Example request:
```json
{"jsonrpc": "2.0", "method": "get_dashboard", "params": {}, "id": 1}
```

The Swift IPC client needs:
- Unix socket connection (Foundation `FileHandle` or SwiftNIO)
- JSON encoding/decoding (Foundation `JSONSerialization` or `Codable`)
- Async request/response
- Notification listener (daemon pushes events)

## Dependencies
- PineUI (this project)
- Foundation (JSON, sockets)
- No additional Swift packages needed

## Custom Widgets Needed
- BarChart (Meridian uses custom cairo-drawn charts)
- BurndownChart
- PR Health indicators
- These could use PineUI's `Path` shape or Cairo drawing via CGTK4
