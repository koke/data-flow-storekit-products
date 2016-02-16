import UIKit
import StoreKit

class PlansListViewController: UITableViewController, SKProductsRequestDelegate {
    // ...

    let identifiers = Set([ "com.wordpress.test.premium.1year", "com.wordpress.test.business.1year"])

    var request: SKProductsRequest? = nil

    deinit {
        if let request = self.request {
            request.delegate = nil
            request.cancel()
        }
    }

    func fetchProducts() {
        guard self.request == nil else {
            return
        }
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        request.start()
        self.request = request
    }

    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products = response.products
        // Reload data showing products
    }
}


