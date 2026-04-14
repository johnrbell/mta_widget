import SwiftUI
import WidgetKit

enum WidgetSizeTab: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var smallConfig = SharedDefaults.shared.smallWidgetConfig
    @State private var mediumConfig = SharedDefaults.shared.mediumWidgetConfig
    @State private var trainStatus: TrainStatusResult?
    @State private var isLoading = false
    @State private var showOnboarding = false
    @State private var errorMessage: String?
    @State private var lastRefresh: Date?
    @State private var selectedFamily: WidgetSizeTab = .small

    private var activeConfig: Binding<WidgetConfig> {
        switch selectedFamily {
        case .small: return $smallConfig
        case .medium: return $mediumConfig
        }
    }

    private var routeLimit: Int {
        selectedFamily == .small ? 4 : 8
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    familyPicker
                    previewSection
                    trainPickerSection
                    slidersSection
                    themeSection
                    statusBar
                    addWidgetButton
                }
                .padding()
                .animation(.easeInOut(duration: 0.25), value: activeConfig.wrappedValue.selectedRoutes)
                .animation(.easeInOut(duration: 0.25), value: activeConfig.wrappedValue.theme)
            }
            .navigationTitle("NYC Transit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await refreshData() }
                    } label: {
                        if isLoading {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .task { await refreshData() }
            .sheet(isPresented: $showOnboarding) { OnboardingSheet() }
            .onChange(of: smallConfig) { _, newValue in
                SharedDefaults.shared.smallWidgetConfig = newValue
            }
            .onChange(of: mediumConfig) { _, newValue in
                SharedDefaults.shared.mediumWidgetConfig = newValue
            }
        }
    }

    // MARK: - Family Picker

    private var familyPicker: some View {
        Picker("Widget Size", selection: $selectedFamily) {
            ForEach(WidgetSizeTab.allCases) { family in
                Text(family.rawValue).tag(family)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)

            Group {
                switch selectedFamily {
                case .small:
                    WidgetPreviewView(config: smallConfig, trainStatus: trainStatus, family: .systemSmall)
                        .frame(width: 170, height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                case .medium:
                    WidgetPreviewView(config: mediumConfig, trainStatus: trainStatus, family: .systemMedium)
                        .frame(width: 340, height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Train Picker

    private var trainPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trains")
                    .font(.headline)
                Spacer()
                Text("\(activeConfig.wrappedValue.trainCount)/\(routeLimit)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            TrainPickerView(config: activeConfig, trainStatus: trainStatus, routeLimit: routeLimit)
        }
    }

    // MARK: - Sliders

    private var slidersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sizing")
                .font(.headline)

            VStack(spacing: 12) {
                sliderRow(label: "Circle", value: activeConfig.circleSize, range: 20...80, step: 2)
                sliderRow(label: "Font", value: activeConfig.fontSize, range: 8...16, step: 1)
                sliderRow(label: "H Gap", value: activeConfig.hSpacing, range: 0...16, step: 1)
                sliderRow(label: "V Gap", value: activeConfig.vSpacing, range: 0...16, step: 1)
            }
        }
    }

    private func sliderRow(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.subheadline)
                .frame(width: 56, alignment: .leading)
            Slider(value: value, in: range, step: step)
            Text("\(Int(value.wrappedValue))")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .trailing)
        }
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.headline)
            ThemePickerView(selectedTheme: activeConfig.theme)
        }
    }

    // MARK: - Status

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
                .frame(maxWidth: .infinity)
        }
    }

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
    }

    // MARK: - Data

    private func refreshData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            trainStatus = try await TransitService.shared.fetchTrainData(bypassCache: true)
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
