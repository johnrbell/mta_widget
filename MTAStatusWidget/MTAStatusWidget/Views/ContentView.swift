import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var config = SharedDefaults.shared.widgetConfig
    @State private var trainStatus: TrainStatusResult?
    @State private var isLoading = false
    @State private var showOnboarding = false
    @State private var errorMessage: String?
    @State private var lastRefresh: Date?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    widgetPreviewSection
                    trainPickerSection
                    themeSection
                    layoutSection
                    statusBar
                    addWidgetButton
                }
                .padding()
                .animation(.easeInOut(duration: 0.25), value: config.selectedRoutes)
                .animation(.easeInOut(duration: 0.25), value: config.theme)
                .animation(.easeInOut(duration: 0.25), value: config.layout)
            }
            .navigationTitle("MTA Widget")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await refreshData() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(isLoading)
                    .accessibilityLabel("Refresh train status")
                }
            }
            .task { await refreshData() }
            .sheet(isPresented: $showOnboarding) {
                OnboardingSheet()
            }
        }
    }

    // MARK: - Preview Section

    private var widgetPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Widget Preview")
                .font(.headline)

            HStack(spacing: 16) {
                smallPreview
                mediumPreview
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var smallPreview: some View {
        VStack(spacing: 6) {
            WidgetPreviewView(
                config: config,
                trainStatus: trainStatus,
                family: .systemSmall
            )
            .frame(width: 155, height: 155)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

            Text("Small")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var mediumPreview: some View {
        VStack(spacing: 6) {
            WidgetPreviewView(
                config: config,
                trainStatus: trainStatus,
                family: .systemMedium
            )
            .frame(width: 155, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

            Text("Medium")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Train Picker

    private var trainPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trains")
                    .font(.headline)
                Spacer()
                Text("\(config.selectedRoutes.count)/4")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            TrainPickerView(config: $config, trainStatus: trainStatus)
        }
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.headline)
            ThemePickerView(selectedTheme: $config.theme)
        }
    }

    // MARK: - Layout

    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Layout")
                .font(.headline)
            LayoutPickerView(selectedLayout: $config.layout, trainCount: config.trainCount)
        }
    }

    // MARK: - Status Bar

    @ViewBuilder
    private var statusBar: some View {
        if let errorMessage {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else if let lastRefresh {
            Text("Updated \(lastRefresh, style: .relative) ago")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Add Widget

    private var addWidgetButton: some View {
        Button {
            showOnboarding = true
        } label: {
            Label("How to Add Widget", systemImage: "plus.rectangle.on.rectangle")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(LineColors.color(for: "A"))
        .accessibilityHint("Shows instructions for adding the widget to your home screen")
    }

    // MARK: - Data

    private func refreshData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            trainStatus = try await MTAService.shared.fetchTrainData(bypassCache: true)
            lastRefresh = Date()
        } catch {
            if trainStatus == nil {
                trainStatus = SharedDefaults.shared.cachedTrainStatus
            }
            errorMessage = trainStatus != nil
                ? "Using cached data. Tap refresh to retry."
                : "Could not load train status. Check your connection."
        }
    }
}
