import UIKit
import StoreKit

class StoreService: NSObject, SKProductsRequestDelegate {
    typealias Completion = [SKProduct] -> Void
    let identifiers = Set([ "com.wordpress.test.premium.1year", "com.wordpress.test.business.1year"])
    static let sharedInstance = StoreService()

    var request: SKProductsRequest? = nil
    var products: [SKProduct]? = nil
    var completionBlocks = [Completion]()

    func getProducts(completion: [SKProduct] -> Void) {
        if let products = self.products {
            completion(products)
        } else {
            completionBlocks.append(completion)
            fetchProducts()
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
        products = response.products
        for completion in completionBlocks {
            completion(response.products)
        }
        completionBlocks.removeAll()
    }

}

class PlansListViewController: UITableViewController {
    // ...

    func fetchProducts() {
        StoreService.sharedInstance.getProducts { products in
            // Reload data showing products
        }
    }
}

class PlanDetailsViewController: UITableViewController {
    // ...

    func fetchProducts() {
        StoreService.sharedInstance.getProducts { products in
            // Reload data showing products
        }
    }
}


