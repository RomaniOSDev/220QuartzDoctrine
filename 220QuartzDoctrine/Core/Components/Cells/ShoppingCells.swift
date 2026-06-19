import SwiftUI

struct ShoppingItemCell: View {
    let item: ShoppingItem
    var priceHint: String?
    let onToggle: () -> Void
    @State private var pulseHighlight = false

    private var aisle: AisleCategory {
        AisleCategory(rawValue: item.aisleCategory) ?? .other
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color("AppAccent"))
                    .frame(width: 4)
                    .padding(.vertical, 6)

                ZStack {
                    Circle()
                        .stroke(item.isChecked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.4), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if item.isChecked {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .strikethrough(item.isChecked, color: Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 6) {
                        TagPill(text: "Qty \(item.quantity)")
                        TagPill(text: aisle.rawValue, tint: Color("AppPrimary"))
                    }

                    if let priceHint {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption2)
                            Text(priceHint)
                                .font(.caption2)
                        }
                        .foregroundStyle(Color("AppAccent"))
                    }
                }

                IconBadge(iconName: aisle.iconName, size: 36, tint: Color("AppAccent"))
            }
            .padding(14)
            .background {
                ListCellBackground(
                    cornerRadius: 16,
                    highlighted: pulseHighlight,
                    checked: item.isChecked
                )
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.35), value: pulseHighlight)
        .onChange(of: item.isChecked) { checked in
            if checked {
                pulseHighlight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { pulseHighlight = false }
            }
        }
    }
}

struct AisleGroupHeader: View {
    let aisle: AisleCategory
    let itemCount: Int

    var body: some View {
        HStack(spacing: 10) {
            IconBadge(iconName: aisle.iconName, size: 32, tint: Color("AppAccent"))
            Text(aisle.rawValue)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            Text("\(itemCount)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppAccent"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color("AppAccent").opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}

struct TripModeItemCell: View {
    let item: ShoppingItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            item.isChecked
                                ? AppGradients.accentHighlight
                                : AppGradients.surfaceInset
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundStyle(item.isChecked ? Color("AppAccent") : Color("AppTextSecondary"))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .strikethrough(item.isChecked)
                    HStack(spacing: 8) {
                        TagPill(text: "Qty \(item.quantity)")
                        if let aisle = AisleCategory(rawValue: item.aisleCategory) {
                            TagPill(text: aisle.rawValue, tint: Color("AppPrimary"))
                        }
                    }
                }
                Spacer()
            }
            .padding(16)
            .background {
                ListCellBackground(
                    cornerRadius: 18,
                    checked: item.isChecked
                )
            }
        }
        .buttonStyle(.plain)
        .frame(minHeight: 72)
    }
}

struct StoreChipBar: View {
    let stores: [StoreProfile]
    let selectedId: UUID?
    let onSelect: (StoreProfile) -> Void
    let onAdd: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(stores) { storeProfile in
                    FilterChip(
                        title: storeProfile.name,
                        isSelected: selectedId == storeProfile.id
                    ) {
                        onSelect(storeProfile)
                    }
                }
                AddChipButton(action: onAdd)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

struct SummaryBannerCell: View {
    let leadingTitle: String
    let leadingValue: String
    let trailingText: String
    var iconName: String = "cart.fill"

    var body: some View {
        SurfaceCard(elevation: .floating) {
            HStack(spacing: 14) {
                IconBadge(iconName: iconName, size: 48, tint: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 4) {
                    Text(leadingTitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(leadingValue)
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                Spacer()
                Text(trailingText)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color("AppAccent").opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
