import SwiftUI

struct OnboardingSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    step(number: 1,
                         icon: "hand.tap.fill",
                         title: "Long-press your Home Screen",
                         detail: "Touch and hold an empty area until the apps start jiggling.")

                    step(number: 2,
                         icon: "plus.circle.fill",
                         title: "Tap the + button",
                         detail: "It appears in the top-left corner. Search for \"MTA Widget\".")

                    step(number: 3,
                         icon: "rectangle.badge.plus",
                         title: "Choose a size",
                         detail: "Pick Small (square) or Medium (wide rectangle), then tap \"Add Widget\".")

                    step(number: 4,
                         icon: "checkmark.circle.fill",
                         title: "Done!",
                         detail: "Your widget will update automatically with the latest train status.")
                }
                .padding()
            }
            .navigationTitle("Add Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "widget.small")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Add to Home Screen")
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func step(number: Int, icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(number)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.body.weight(.semibold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
