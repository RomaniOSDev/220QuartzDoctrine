import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var showAddSheet = false
    @State private var templateName = ""
    @State private var isRecurring = false
    @State private var draftItems: [TemplateItem] = []
    @State private var draftItemName = ""
    @State private var draftItemQty = ""
    @State private var draftAisle = AisleCategory.other.rawValue

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                if !store.dueRecurringTemplates.isEmpty {
                    RecurringAlertCell(templates: store.dueRecurringTemplates) { template in
                        FeedbackManager.mediumImpact()
                        let count = store.applyTemplate(template)
                        if count > 0 { FeedbackManager.success() }
                    }
                }

                if store.listTemplates.isEmpty {
                    EmptyStateView(
                        iconName: "doc.on.doc.fill",
                        title: "No templates yet",
                        message: "Create reusable shopping templates to save time",
                        actionTitle: "Create Template"
                    ) {
                        resetDraft()
                        showAddSheet = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(store.listTemplates) { template in
                                TemplateCell(
                                    template: template,
                                    onApply: {
                                        FeedbackManager.mediumImpact()
                                        let count = store.applyTemplate(template)
                                        if count > 0 { FeedbackManager.success() }
                                    },
                                    isDue: template.isDueForRecurrence
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteTemplate(template)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                PrimaryButton(title: "Create Template", iconName: "plus") {
                    FeedbackManager.lightTap()
                    resetDraft()
                    showAddSheet = true
                }
                .padding(16)
            }
        }
        .sheet(isPresented: $showAddSheet) { addTemplateSheet }
    }

    private var addTemplateSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    FormFieldCard(label: "Template Name") {
                        TextField("Weekly Essentials", text: $templateName)
                    }
                    SurfaceCard(elevation: .flat, inset: true) {
                        Toggle("Recurring weekly", isOn: $isRecurring)
                            .tint(Color("AppPrimary"))
                    }
                    FormFieldCard(label: "Add Items") {
                        HStack {
                            TextField("Item", text: $draftItemName)
                            TextField("Qty", text: $draftItemQty)
                                .frame(width: 50)
                            Button {
                                let n = draftItemName.trimmingCharacters(in: .whitespaces)
                                guard !n.isEmpty else { return }
                                draftItems.append(TemplateItem(
                                    name: n,
                                    quantity: draftItemQty.isEmpty ? "1" : draftItemQty,
                                    aisleCategory: draftAisle
                                ))
                                draftItemName = ""
                                draftItemQty = ""
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                        }
                        Picker("Aisle", selection: $draftAisle) {
                            ForEach(AisleCategory.allCases) { aisle in
                                Text(aisle.rawValue).tag(aisle.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    ForEach(draftItems) { item in
                        SurfaceCard(padding: 10, elevation: .flat) {
                            HStack {
                                Text(item.name)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                TagPill(text: item.quantity)
                                TagPill(text: item.aisleCategory, tint: Color("AppPrimary"))
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTemplate() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func saveTemplate() {
        let trimmed = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackManager.warning()
            return
        }
        store.addTemplate(ListTemplate(
            name: trimmed,
            items: draftItems,
            isRecurring: isRecurring,
            recurrenceIntervalDays: 7,
            targetStoreId: store.defaultStoreId
        ))
        FeedbackManager.success()
        showAddSheet = false
    }

    private func resetDraft() {
        templateName = ""
        isRecurring = false
        draftItems = []
        draftItemName = ""
        draftItemQty = ""
        draftAisle = AisleCategory.other.rawValue
    }
}
