import Foundation

enum PriceMemoryCalculator {
    static func allMemories(from purchases: [Purchase]) -> [PriceMemoryInfo] {
        var records: [String: [(price: Double, store: String, date: Date)]] = [:]

        for purchase in purchases {
            let entries = lineEntries(for: purchase)
            for entry in entries {
                let key = entry.name.lowercased().trimmingCharacters(in: .whitespaces)
                guard !key.isEmpty else { continue }
                records[key, default: []].append((entry.price, purchase.storeName, purchase.date))
            }
        }

        return records.map { key, values in
            let prices = values.map(\.price)
            let sorted = values.sorted { $0.date > $1.date }
            let last = sorted.first
            return PriceMemoryInfo(
                itemName: key.capitalized,
                minPrice: prices.min() ?? 0,
                averagePrice: prices.reduce(0, +) / Double(max(prices.count, 1)),
                maxPrice: prices.max() ?? 0,
                lastPrice: last?.price ?? 0,
                lastStore: last?.store ?? "",
                lastDate: last?.date ?? Date(),
                purchaseCount: prices.count
            )
        }
        .sorted { $0.itemName < $1.itemName }
    }

    static func memory(for itemName: String, purchases: [Purchase]) -> PriceMemoryInfo? {
        let key = itemName.lowercased().trimmingCharacters(in: .whitespaces)
        return allMemories(from: purchases).first { $0.id == key }
    }

    static func suggestions(from purchases: [Purchase], limit: Int = 8) -> [String] {
        var counts: [String: Int] = [:]
        for purchase in purchases {
            for entry in lineEntries(for: purchase) {
                let name = entry.name.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { continue }
                counts[name, default: 0] += 1
            }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map(\.key)
    }

    private static func lineEntries(for purchase: Purchase) -> [(name: String, price: Double)] {
        if !purchase.lineItems.isEmpty {
            return purchase.lineItems.map { ($0.name, $0.price) }
        }
        let names = purchase.items
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !names.isEmpty else {
            return [(purchase.items, purchase.totalSpent)]
        }
        let share = purchase.totalSpent / Double(names.count)
        return names.map { ($0, share) }
    }
}
