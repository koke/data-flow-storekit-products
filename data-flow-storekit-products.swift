import UIKit
import StoreKit

class StoreService: NSObject, SKProductsRequestDelegate {
    typealias Completion = ([SKProduct]?, ErrorType?) -> Void
    let identifiers = Set([ "com.wordpress.test.premium.1year", "com.wordpress.test.business.1year"])
    static let sharedInstance = StoreService()

    var request: SKProductsRequest? = nil
    var products: [SKProduct]? = nil
    var completionBlocks = [Completion]()

    func getProducts(completion: Completion) {
        if let products = self.products {
            completion(products, nil)
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
            completion(response.products, nil)
        }
        completionBlocks.removeAll()
    }

    func request(request: SKRequest, didFailWithError error: NSError) {
        for completion in completionBlocks {
            completion(nil, error)
        }
        completionBlocks.removeAll()
    }
}

class PlansListViewController: UITableViewController {
    // ...

    func fetchProducts() {
        StoreService.sharedInstance.getProducts { products, error in
            if let products = products {
                // Reload data showing products
            } else if let error = error {
                // Show error
            } else {
                // Shouldn't happen
            }
        }
    }
}

class PlanDetailsViewController: UITableViewController {
    // ...

    func fetchProducts() {
        StoreService.sharedInstance.getProducts { products, error in
            if let products = products {
                // Reload data showing products
            } else if let error = error {
                // Show error
            } else {
                // Shouldn't happen
            }
        }
    }
}


