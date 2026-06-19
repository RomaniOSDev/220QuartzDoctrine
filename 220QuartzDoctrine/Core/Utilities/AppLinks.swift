import StoreKit
import UIKit

enum AppLink: String {
    case privacyPolicy = "https://quartz220doctrine.site/privacy/258"
    case termsOfService = "https://quartz220doctrine.site/terms/258"

    func open() {
        if let url = URL(string: rawValue) {
            UIApplication.shared.open(url)
        }
    }
}

enum AppReview {
    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
