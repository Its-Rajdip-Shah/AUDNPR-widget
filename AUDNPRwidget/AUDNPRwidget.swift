import WidgetKit
import SwiftUI
import AppKit

// MARK: - Timeline

struct RateEntry: TimelineEntry {
    let date: Date
    let rate: Double?
    let base: String
    let quote: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> RateEntry {
        RateEntry(date: Date(), rate: 88.7654, base: "AUD", quote: "NPR")
    }

    func getSnapshot(in context: Context, completion: @escaping (RateEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RateEntry>) -> Void) {
        Task {
            let base = "AUD", quote = "NPR"
            let rate = try? await RateFetcher.fetch(base: base, quote: quote)

            let entry = RateEntry(date: Date(), rate: rate, base: base, quote: quote)

            // Refresh again in 8 hours instead of 12
            let next = Calendar.current.date(byAdding: .hour, value: 8, to: Date())!

            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

}

// MARK: - View


struct AUDNPRWidgetEntryView: View {
    var entry: Provider.Entry

    // Tweak how tiny the inner content looks inside the small widget (0.40–0.90)
    private let scale: CGFloat = 0.55

    private func fmt(_ v: Double) -> String { String(format: "%.1f", v) }

    var body: some View {
        let content = GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)

            // The rate (only)
            Text(entry.rate.map(fmt) ?? "—")
                .font(.system(size: side * 0.35 * scale, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(width: side * scale, height: side * scale)
                .contentShape(Rectangle())
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .foregroundStyle(.primary) // uses system vibrancy for contrast
        }
        .padding(0)

        if #available(macOS 14.0, *) {
            content
                .containerBackground(for: .widget) {
                    // Glassmorphism panel (rounded, blurred, frosted)
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial) // frosted blur that reacts to wallpaper
                        // subtle top-left highlight → bottom-right fade (glass sheen)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.28),
                                    .white.opacity(0.10),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        )
                        // inner hairline for “pane” edge
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        )
                        // faint outer shadow for lift (kept subtle so it still feels native)
                        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
        } else {
            // macOS 13 fallback (no containerBackground)
            content
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        )
                )
        }
    }
}





// MARK: - Widget

struct AUDNPRWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AUDNPRWidget", provider: Provider()) { entry in
            AUDNPRWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AUD → NPR")
        .description("Live AUD to NPR rate, refreshes every 12 hours.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
