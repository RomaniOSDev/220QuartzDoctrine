import SwiftUI

struct PantryItemCell: View {
    let item: PantryItem
    let onStatusChange: (PantryStockStatus) -> Void

    private var statusStyle: (color: Color, icon: String) {
        switch item.status {
        case .inStock: return (Color("AppAccent"), "checkmark.seal.fill")
        case .runningLow: return (Color("AppPrimary"), "exclamationmark.triangle.fill")
        case .outOfStock: return (Color("AppPrimary"), "xmark.circle.fill")
        }
    }

    private var expiryWarning: Bool {
        guard let expiry = item.expiryDate else { return false }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0
        return days <= 3
    }

    var body: some View {
        SurfaceCard(padding: 0, elevation: .flat, showBorder: true) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    IconBadge(iconName: "archivebox.fill", size: 46, tint: statusStyle.color)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        HStack(spacing: 6) {
                            TagPill(text: "\(item.quantity) \(item.unit)")
                            TagPill(text: item.status.rawValue, tint: statusStyle.color)
                        }

                        if let expiry = item.expiryDate {
                            HStack(spacing: 4) {
                                Image(systemName: expiryWarning ? "clock.badge.exclamationmark" : "calendar")
                                    .font(.caption2)
                                Text("Expires \(expiry.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                            }
                            .foregroundStyle(expiryWarning ? Color("AppPrimary") : Color("AppTextSecondary"))
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: statusStyle.icon)
                        .font(.title3)
                        .foregroundStyle(statusStyle.color)
                }
                .padding(14)

                Divider().background(Color("AppAccent").opacity(0.12))

                HStack(spacing: 8) {
                    ForEach(PantryStockStatus.allCases, id: \.self) { status in
                        Button {
                            FeedbackManager.lightTap()
                            onStatusChange(status)
                        } label: {
                            Text(shortLabel(for: status))
                                .font(.caption2.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(item.status == status ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background {
                                    if item.status == status {
                                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                                            .fill(AppGradients.primaryButton)
                                    } else {
                                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                                            .fill(AppGradients.surfaceInset)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    private func shortLabel(for status: PantryStockStatus) -> String {
        switch status {
        case .inStock: return "In Stock"
        case .runningLow: return "Low"
        case .outOfStock: return "Empty"
        }
    }
}

struct PantryStatsRow: View {
    let inStock: Int
    let runningLow: Int
    let outOfStock: Int

    var body: some View {
        HStack(spacing: 10) {
            miniStat(value: inStock, label: "Stocked", tint: Color("AppAccent"))
            miniStat(value: runningLow, label: "Low", tint: Color("AppPrimary"))
            miniStat(value: outOfStock, label: "Empty", tint: Color("AppPrimary"))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func miniStat(value: Int, label: String, tint: Color) -> some View {
        SurfaceCard(padding: 10, elevation: .raised) {
            VStack(spacing: 4) {
                Text("\(value)")
                    .font(.title3.bold())
                    .foregroundStyle(tint)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
