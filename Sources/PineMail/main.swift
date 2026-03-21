// PineMail — 1:1 port of Apple Mail (macOS Tahoe) UI frame.
//
// This is the visual frame only — no actual email functionality yet.
// Layout: Sidebar | Message List | Message Preview (3-column)

import PineUI

// MARK: - Mock Data

struct Email {
    let id: Int
    let from: String
    let fromEmail: String
    let to: String
    let subject: String
    let preview: String
    let body: String
    let date: String
    let time: String
    let isRead: Bool
    let isFlagged: Bool
    let hasAttachment: Bool
}

let mockEmails: [Email] = [
    Email(id: 1, from: "Alice Chen", fromEmail: "alice@example.com", to: "You",
          subject: "Meeting tomorrow",
          preview: "Just confirming our meeting at 2pm tomorrow. I've attached the agenda...",
          body: "Hi,\n\nJust confirming our meeting at 2pm tomorrow in Conference Room B.\n\nI've attached the agenda for your review. The main topics are:\n\n1. Q2 roadmap priorities\n2. PineUI framework progress\n3. Hiring timeline\n\nPlease let me know if you have any items to add.\n\nBest,\nAlice",
          date: "Today", time: "10:32 AM", isRead: false, isFlagged: true, hasAttachment: true),
    Email(id: 2, from: "Bob Martinez", fromEmail: "bob@company.com", to: "Team",
          subject: "Re: Q2 Planning",
          preview: "Sounds good. I'll update the sprint board with the new priorities...",
          body: "Thanks for the update.\n\nI'll update the sprint board with the new priorities by end of day.\n\nOne question — should we move the API refactor to Q3 or keep it in Q2?\n\n— Bob",
          date: "Today", time: "9:15 AM", isRead: false, isFlagged: false, hasAttachment: false),
    Email(id: 3, from: "Accounting", fromEmail: "invoices@company.com", to: "You",
          subject: "Invoice #1234 — March 2026",
          preview: "Your invoice for March 2026 is ready for review...",
          body: "Dear Sean,\n\nYour invoice #1234 for the period March 1-31, 2026 has been generated.\n\nAmount: $8,500.00\nDue Date: April 15, 2026\nStatus: Pending\n\nPlease review and approve at your earliest convenience.\n\nRegards,\nAccounting Department",
          date: "Yesterday", time: "4:30 PM", isRead: true, isFlagged: false, hasAttachment: true),
    Email(id: 4, from: "Pine Ridge Labs", fromEmail: "noreply@pinyridgelabs.com", to: "You",
          subject: "Welcome aboard!",
          preview: "Welcome to Pine Ridge Labs. Here's everything you need to get started...",
          body: "Welcome to Pine Ridge Labs!\n\nWe're excited to have you on board. Here are a few things to get you started:\n\n• Set up your development environment\n• Review the CLAUDE.md in each project\n• Join #engineering on Slack\n• Check out the PineUI component gallery\n\nDon't hesitate to reach out if you need anything.\n\n— The Team",
          date: "Mar 18", time: "2:00 PM", isRead: true, isFlagged: false, hasAttachment: false),
    Email(id: 5, from: "GitHub", fromEmail: "notifications@github.com", to: "You",
          subject: "[sean-rowe/PineUI] PR #12 merged",
          preview: "Pull request #12 'Add SwiftUI modifier parity' has been merged...",
          body: "Pull Request #12\nAdd SwiftUI modifier parity\n\nMerged by sean-rowe\n\n152 modifiers across 12 categories\n586 tests, 0 failures\n\n---\nYou are receiving this because you are subscribed to this repository.",
          date: "Mar 17", time: "11:45 PM", isRead: true, isFlagged: false, hasAttachment: false),
    Email(id: 6, from: "Carol Wright", fromEmail: "carol@design.co", to: "You",
          subject: "Liquid Glass design assets",
          preview: "Here are the updated design assets for the Tahoe theme...",
          body: "Hi Sean,\n\nAttached are the updated Liquid Glass design assets you requested:\n\n• Color palette (dark + light mode)\n• Component specifications\n• Icon set (SF Symbol mappings)\n• Typography scale\n\nLet me know if you need any revisions.\n\nCarol",
          date: "Mar 15", time: "3:22 PM", isRead: true, isFlagged: true, hasAttachment: true),
]

// MARK: - State

let selectedEmail = StateStore<Int>(1)  // selected email id
let selectedMailbox = StateStore<String>("all-inboxes")

// MARK: - App

struct MailApp: PineApp {
    var appId: String { "com.pinyridgelabs.Mail" }

    func buildWindow() -> PineWindow {
        PineWindow("Mail", width: 1400, height: 900)
            .toolbar(PineToolbar()
                // Left group — message actions
                .leading("Sidebar", icon: "sidebar.left") { }
                .leading("Archive", icon: "archivebox") { }
                .leading("Junk", icon: "xmark.circle") { }
                .leading("Delete", icon: "trash") { }
                // Right group — compose & search
                .trailing("Compose", icon: "square.and.pencil") { }
                .trailing("Search", icon: "magnifyingglass") { }
                .trailing("Reply", icon: "arrow.uturn.backward") { }
            )
            .sidebar(buildSidebar())
            .content {
                buildContentArea()
            }
            .statusBar(PineStatusBar()
                .left(StatusItem("3 messages, 2 unread"))
                .right(StatusItem("Updated just now", icon: "checkmark.circle"))
            )
    }
}

// MARK: - Sidebar

func buildSidebar() -> PineSidebar {
    PineSidebar()
        .section("Favorites", items: [
            SidebarItem("All Inboxes", icon: "tray", badge: 2, id: "all-inboxes"),
            SidebarItem("Flagged", icon: "flag.fill", badge: 2, id: "flagged"),
            SidebarItem("Sent", icon: "paperplane", id: "sent"),
            SidebarItem("Drafts", icon: "doc.text", id: "drafts"),
            SidebarItem("Trash", icon: "trash", id: "trash"),
            SidebarItem("Archive", icon: "archivebox", id: "archive"),
        ])
        .section("Mailboxes", items: [
            SidebarItem("iCloud", icon: "envelope", badge: 1, id: "icloud"),
            SidebarItem("Gmail", icon: "envelope", badge: 1, id: "gmail"),
            SidebarItem("Work", icon: "envelope", id: "work"),
        ])
        .section("Smart Mailboxes", items: [
            SidebarItem("Today", icon: "clock", id: "today"),
            SidebarItem("Attachments", icon: "doc.richtext", id: "attachments"),
            SidebarItem("Unread", icon: "envelope.badge", id: "unread"),
        ])
        .onSelection { mailboxId in
            selectedMailbox.value = mailboxId
        }
}

// MARK: - Content Area (Message List + Preview in HSplitView)

func buildContentArea() -> WidgetPtr {
    // Use raw GTK for the split view since .content expects WidgetPtr
    let paned = gtk_paned_new(GTK_ORIENTATION_HORIZONTAL)!
    let p = OpaquePointer(paned)
    setHExpand(paned)
    setVExpand(paned)

    // Left: Message List
    let listContainer = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
    setSizeRequest(listContainer, width: 340, height: -1)

    // Search bar at top of message list
    let searchRow = render(
        HStack(spacing: 0) {
            SearchField("Search Mail") { _ in }
        }
        .padding(8)
    )
    boxAppend(listContainer, child: searchRow)

    // Divider
    let sep = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)!
    boxAppend(listContainer, child: sep)

    // Message list (reactive — rebuilds when selection changes)
    let listScroll = makeScrolledWindow()
    setVExpand(listScroll)
    scrolledWindowSetPolicy(listScroll, h: GTK_POLICY_NEVER, v: GTK_POLICY_AUTOMATIC)

    let messageList = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)

    for email in mockEmails {
        boxAppend(messageList, child: buildMessageRow(email))
    }

    scrolledWindowSetChild(listScroll, child: messageList)
    boxAppend(listContainer, child: listScroll)

    gtk_paned_set_start_child(p, listContainer)

    // Right: Message Preview
    let previewWidget = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
    setHExpand(previewWidget)
    setVExpand(previewWidget)

    // Build initial preview
    reactive(in: previewWidget, state: selectedEmail) { emailId in
        guard let email = mockEmails.first(where: { $0.id == emailId }) else {
            return render(
                ContentUnavailableView("No Message Selected", systemImage: "envelope",
                    description: "Select a message from the list to read it")
            )
        }
        return buildMessagePreview(email)
    }

    gtk_paned_set_end_child(p, previewWidget)
    gtk_paned_set_position(p, 340)

    return paned
}

// MARK: - Message Row (in message list)

func buildMessageRow(_ email: Email) -> WidgetPtr {
    let row = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 2)
    setMargins(row, start: 12, end: 12, top: 8, bottom: 8)

    // Unread indicator + sender row
    let topRow = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 6)
    setHExpand(topRow)

    // Blue dot for unread
    if !email.isRead {
        let dot = makeLabel("\u{2022}")  // bullet
        applyCss(dot, "color: #0088FF; font-size: 1.2em;")
        boxAppend(topRow, child: dot)
    }

    // Flag indicator
    if email.isFlagged {
        let flag = makeImage(iconName: resolveSFSymbol("flag.fill"))
        applyCss(flag, "color: #E9873A;")
        boxAppend(topRow, child: flag)
    }

    // Sender name
    let sender = makeLabel(email.from)
    if !email.isRead {
        addCssClass(sender, "pine-headline")
    }
    setHAlign(sender, align: GTK_ALIGN_START)
    setHExpand(sender)
    boxAppend(topRow, child: sender)

    // Time/date
    let time = makeLabel(email.time)
    addCssClass(time, "pine-caption")
    boxAppend(topRow, child: time)

    // Attachment icon
    if email.hasAttachment {
        let clip = makeImage(iconName: resolveSFSymbol("doc.richtext"))
        applyCss(clip, "color: #999999;")
        boxAppend(topRow, child: clip)
    }

    boxAppend(row, child: topRow)

    // Subject
    let subject = makeLabel(email.subject)
    if !email.isRead {
        addCssClass(subject, "pine-bold")
    }
    setHAlign(subject, align: GTK_ALIGN_START)
    boxAppend(row, child: subject)

    // Preview text
    let preview = makeLabel(email.preview)
    addCssClass(preview, "pine-caption")
    setHAlign(preview, align: GTK_ALIGN_START)
    gtk_label_set_ellipsize(OpaquePointer(preview), PANGO_ELLIPSIZE_END)
    gtk_label_set_lines(OpaquePointer(preview), 2)
    boxAppend(row, child: preview)

    // Bottom separator
    let rowSep = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)!
    applyCss(rowSep, "background: rgba(255,255,255,0.06); min-height: 1px;")
    boxAppend(row, child: rowSep)

    // Wrap in button for click handling
    let button = makeButton()
    buttonSetHasFrame(button, hasFrame: false)
    buttonSetChild(button, child: row)
    setHExpand(button)
    applyCss(button, "padding: 0; border-radius: 0;")

    // Click handler
    let handler = EmailClickHandler(emailId: email.id)
    let ptr = Unmanaged.passRetained(handler).toOpaque()
    let callback: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
        guard let userData = userData else { return }
        let h = Unmanaged<EmailClickHandler>.fromOpaque(userData).takeUnretainedValue()
        selectedEmail.value = h.emailId
    }
    g_signal_connect_data(
        UnsafeMutableRawPointer(button), "clicked",
        unsafeBitCast(callback, to: GCallback.self),
        ptr, { userData, _ in
            guard let userData = userData else { return }
            Unmanaged<EmailClickHandler>.fromOpaque(userData).release()
        }, GConnectFlags(rawValue: 0)
    )

    return button
}

private class EmailClickHandler {
    let emailId: Int
    init(emailId: Int) { self.emailId = emailId }
}

// MARK: - Message Preview

func buildMessagePreview(_ email: Email) -> WidgetPtr {
    let container = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
    setHExpand(container)
    setVExpand(container)

    // Header area
    let header = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 8)
    setMargins(header, start: 24, end: 24, top: 20, bottom: 16)

    // Subject line
    let subjectLabel = makeLabel(email.subject)
    addCssClass(subjectLabel, "pine-title2")
    setHAlign(subjectLabel, align: GTK_ALIGN_START)
    boxAppend(header, child: subjectLabel)

    // From row
    let fromRow = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
    setHExpand(fromRow)

    // Avatar
    let avatarWidget = render(Avatar(String(email.from.prefix(2).uppercased()), size: 36))
    boxAppend(fromRow, child: avatarWidget)

    // From details
    let fromDetails = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 1)

    let fromName = makeLabel(email.from)
    addCssClass(fromName, "pine-headline")
    setHAlign(fromName, align: GTK_ALIGN_START)
    boxAppend(fromDetails, child: fromName)

    let fromEmail = makeLabel("To: \(email.to)  •  \(email.date) \(email.time)")
    addCssClass(fromEmail, "pine-caption")
    setHAlign(fromEmail, align: GTK_ALIGN_START)
    boxAppend(fromDetails, child: fromEmail)

    setHExpand(fromDetails)
    boxAppend(fromRow, child: fromDetails)

    // Action buttons (right side of from row)
    let actions = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 4)

    let replyBtn = render(Button("Reply") { }.buttonStyle(.bordered))
    boxAppend(actions, child: replyBtn)

    let forwardBtn = render(Button("Forward") { }.buttonStyle(.bordered))
    boxAppend(actions, child: forwardBtn)

    if email.isFlagged {
        let flagChip = render(Chip("Flagged", color: .orange))
        boxAppend(actions, child: flagChip)
    }

    if email.hasAttachment {
        let attachChip = render(Chip("Attachment", color: .blue))
        boxAppend(actions, child: attachChip)
    }

    boxAppend(fromRow, child: actions)
    boxAppend(header, child: fromRow)

    boxAppend(container, child: header)

    // Divider
    let headerSep = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)!
    boxAppend(container, child: headerSep)

    // Message body
    let bodyScroll = makeScrolledWindow()
    setVExpand(bodyScroll)
    setHExpand(bodyScroll)
    scrolledWindowSetPolicy(bodyScroll, h: GTK_POLICY_NEVER, v: GTK_POLICY_AUTOMATIC)

    let bodyText = gtk_text_view_new()!
    let tv: UnsafeMutablePointer<GtkTextView> = typed(bodyText)
    gtk_text_view_set_wrap_mode(tv, GTK_WRAP_WORD_CHAR)
    gtk_text_view_set_editable(tv, 0)
    gtk_text_view_set_cursor_visible(tv, 0)
    gtk_text_view_set_left_margin(tv, 24)
    gtk_text_view_set_right_margin(tv, 24)
    gtk_text_view_set_top_margin(tv, 16)
    gtk_text_view_set_bottom_margin(tv, 16)
    applyCss(bodyText, "background: none; color: #dedede; font-size: 1.0em;")

    let buffer = gtk_text_view_get_buffer(tv)
    gtk_text_buffer_set_text(buffer, email.body, Int32(email.body.utf8.count))

    scrolledWindowSetChild(bodyScroll, child: bodyText)
    boxAppend(container, child: bodyScroll)

    return container
}

// MARK: - Launch

MailApp.main()
