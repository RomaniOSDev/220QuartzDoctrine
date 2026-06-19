import SwiftUI

struct SpendingInsightsView: View {
    var embeddedInTrack = false
    @StateObject private var viewModel = SpendingInsightsViewModel()
    @State private var chartSegment = 1

    var body: some View {
        Group {
            if embeddedInTrack { content } else { NavigationStack { content } }
        }
    }

    private var content: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isEmpty {
                        EmptyStateView(
                            iconName: "cart.fill",
                            title: "Unlock insights",
                            message: "Track your purchases to unlock insights!",
                            actionTitle: "Add Purchase"
                        ) {
                            viewModel.openAddSheet()
                        }
                        .frame(minHeight: 320)
                    } else {
                        statsCards
                        chartSection
                    }

                    PrimaryButton(title: "Add Purchases", iconName: "plus") {
                        viewModel.openAddSheet()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
        }
        .modifier(EmbeddedNavigationModifier(embedded: embeddedInTrack, title: "Spending Insights"))
        .sheet(isPresented: $viewModel.showAddSheet) { addPurchaseSheet }
        .onAppear { syncChartSegment() }
        .onChange(of: viewModel.chartTimeframe) { _ in syncChartSegment() }
    }

    private var statsCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                InsightStatCell(
                    title: "Total Spend",
                    value: String(format: "$%.2f", viewModel.totalSpend),
                    iconName: "dollarsign.circle.fill"
                )
                InsightStatCell(
                    title: "Monthly Average",
                    value: String(format: "$%.2f", viewModel.monthlyAverage),
                    iconName: "calendar"
                )
                InsightStatCell(
                    title: "Items Purchased",
                    value: "\(viewModel.itemsPurchased)",
                    iconName: "bag.fill"
                )
            }
            .padding(.horizontal, 16)
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            StyledSegmentedPicker(
                selection: $chartSegment,
                labels: SpendingInsightsViewModel.ChartTimeframe.allCases.map(\.rawValue)
            )
            .onChange(of: chartSegment) { index in
                let all = SpendingInsightsViewModel.ChartTimeframe.allCases
                guard index < all.count else { return }
                viewModel.selectTimeframe(all[index])
            }

            SurfaceCard(elevation: .floating) {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(
                        title: "Expenditure",
                        subtitle: "Swipe chart to change period",
                        iconName: "chart.bar.fill"
                    )
                    SpendingChartView(data: viewModel.chartData, maxValue: viewModel.maxChartValue)
                        .scaleEffect(viewModel.chartGrowthScale)
                        .frame(height: 180)
                        .gesture(
                            DragGesture(minimumDistance: 30)
                                .onEnded { value in
                                    if value.translation.width < -30 {
                                        cycleTimeframe(forward: true)
                                    } else if value.translation.width > 30 {
                                        cycleTimeframe(forward: false)
                                    }
                                }
                        )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func syncChartSegment() {
        if let index = SpendingInsightsViewModel.ChartTimeframe.allCases.firstIndex(of: viewModel.chartTimeframe) {
            chartSegment = index
        }
    }

    private func cycleTimeframe(forward: Bool) {
        let all = SpendingInsightsViewModel.ChartTimeframe.allCases
        guard let index = all.firstIndex(of: viewModel.chartTimeframe) else { return }
        let nextIndex = forward ? min(index + 1, all.count - 1) : max(index - 1, 0)
        if nextIndex != index {
            FeedbackManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.chartTimeframe = all[nextIndex]
                chartSegment = nextIndex
            }
        }
    }

    private var addPurchaseSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FormFieldCard(label: "Date") {
                        DatePicker("", selection: $viewModel.purchaseDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    FormFieldCard(label: "Store") {
                        TextField("Store name", text: $viewModel.storeName)
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                    }
                    if let error = viewModel.storeError {
                        Text(error).font(.caption).foregroundStyle(Color("AppPrimary"))
                    }
                    FormFieldCard(label: "Items") {
                        TextField("Items", text: $viewModel.itemsText)
                    }
                    FormFieldCard(label: "Total ($)") {
                        TextField("0.00", text: $viewModel.totalSpentText)
                            .keyboardType(.decimalPad)
                    }
                    if let error = viewModel.amountError {
                        Text(error).font(.caption).foregroundStyle(Color("AppPrimary"))
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Add Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        viewModel.showAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.savePurchase() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct SpendingChartView: View {
    let data: [(label: String, amount: Double)]
    let maxValue: Double

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 6) {
                    Text(item.amount > 0 ? String(format: "$%.0f", item.amount) : "")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color("AppAccent"))
                        .frame(height: 12)

                    Canvas { context, size in
                        let barHeight = maxValue > 0
                            ? CGFloat(item.amount / maxValue) * size.height
                            : 0
                        let rect = CGRect(
                            x: 0,
                            y: size.height - barHeight,
                            width: size.width,
                            height: max(barHeight, 3)
                        )
                        context.fill(
                            Path(roundedRect: rect, cornerRadius: 5),
                            with: .color(Color("AppAccent"))
                        )
                    }
                    .frame(height: 120)

                    Text(item.label)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
