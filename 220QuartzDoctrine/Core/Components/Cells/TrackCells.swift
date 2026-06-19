import SwiftUI

struct PurchaseCardCell: View {
    let purchase: Purchase
    @Binding var isExpanded: Bool

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    var body: some View {
        SurfaceCard(padding: 0, elevation: .flat) {
            VStack(spacing: 0) {
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 14) {
                        IconBadge(iconName: "doc.text.fill", size: 44, tint: Color("AppAccent"))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(purchase.storeName)
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(dateFormatter.string(from: purchase.date))
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            TagPill(text: purchase.budgetCategory, tint: Color("AppPrimary"))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text(String(format: "$%.2f", purchase.totalSpent))
                                .font(.title3.bold())
                                .foregroundStyle(Color("AppAccent"))
                            if purchase.reviewed {
                                Label("Reviewed", systemImage: "checkmark.seal.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppAccent"))
                            }
                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .padding(14)
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Divider().background(Color("AppAccent").opacity(0.12))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Items")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text(purchase.items)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        if !purchase.lineItems.isEmpty {
                            ForEach(purchase.lineItems) { line in
                                HStack {
                                    Text(line.name)
                                    Spacer()
                                    Text(String(format: "$%.2f", line.price))
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                    }
                    .padding(14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

struct PriceMemoryCell: View {
    let memory: PriceMemoryInfo

    var body: some View {
        SurfaceCard(elevation: .flat) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    IconBadge(iconName: "tag.fill", size: 40, tint: Color("AppAccent"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(memory.itemName)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(memory.formattedLastPaid)
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                    Spacer()
                    Text("\(memory.purchaseCount)×")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                HStack(spacing: 8) {
                    priceStat("Min", memory.minPrice)
                    priceStat("Avg", memory.averagePrice)
                    priceStat("Max", memory.maxPrice)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    private func priceStat(_ label: String, _ value: Double) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
            Text(String(format: "$%.2f", value))
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppGradients.surfaceInset)
        }
    }
}

struct BudgetOverviewCell: View {
    let title: String
    let spent: Double
    let limit: Double
    let remaining: Double

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1)
    }

    var body: some View {
        SurfaceCard(elevation: .floating) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text(String(format: "$%.0f left", remaining))
                        .font(.caption.bold())
                        .foregroundStyle(spent > limit ? Color("AppPrimary") : Color("AppAccent"))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppGradients.surfaceInset)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: spent > limit
                                        ? [Color("AppPrimary"), Color("AppPrimary").opacity(0.7)]
                                        : [Color("AppAccent"), Color("AppPrimary")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("Spent \(String(format: "$%.2f", spent))")
                    Spacer()
                    Text("Limit \(String(format: "$%.0f", limit))")
                }
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
    }
}

struct CategoryBudgetCell: View {
    let category: String
    let spent: Double
    let limit: Double

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1)
    }

    var body: some View {
        SurfaceCard(padding: 12, elevation: .flat) {
            HStack(spacing: 12) {
                IconBadge(iconName: iconForCategory, size: 36, tint: Color("AppAccent"))
                VStack(alignment: .leading, spacing: 6) {
                    Text(category)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    if limit > 0 {
                        ProgressView(value: progress)
                            .tint(spent > limit ? Color("AppPrimary") : Color("AppAccent"))
                        Text("\(String(format: "$%.0f", spent)) / \(String(format: "$%.0f", limit))")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    } else {
                        Text("No limit set")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var iconForCategory: String {
        switch category {
        case "Groceries": return "cart.fill"
        case "Household": return "house.fill"
        case "Pharmacy": return "cross.case.fill"
        default: return "bag.fill"
        }
    }
}

struct InsightStatCell: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        SurfaceCard(padding: 14, elevation: .raised) {
            VStack(alignment: .leading, spacing: 10) {
                IconBadge(iconName: iconName, size: 36, tint: Color("AppPrimary"))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 150, alignment: .leading)
        }
    }
}
