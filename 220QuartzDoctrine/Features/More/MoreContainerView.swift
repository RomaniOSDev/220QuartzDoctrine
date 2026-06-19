import SwiftUI

struct MoreContainerView: View {
    @State private var section = 0

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    StyledSegmentedPicker(selection: $section, labels: ["Stats", "Settings"])

                    if section == 0 {
                        StatsView(embedded: true)
                    } else {
                        SettingsView(embedded: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(section == 0 ? "Achievements" : "Settings")
            .navigationBarTitleDisplayMode(.large)
            .appNavigationBarStyle()
        }
    }
}
