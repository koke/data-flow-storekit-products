import UIKit
import StoreKit

class PlanListViewController: UITableViewController, SKProductsRequestDelegate {
    // ...
    let identifiers = Set([ "com.wordpress.test.premium.1year", "com.wordpress.test.business.1year"])

    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.start()
    }

    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products = response.products
        // Reload data showing products
    }
}


