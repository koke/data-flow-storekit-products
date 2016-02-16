import UIKit
import StoreKit

class StoreService: NSObject, SKProductsRequestDelegate {
    enum Result {
        case Success([SKProduct])
        case Failure(ErrorType)
    }

    typealias Completion = (Result) -> Void
    let identifiers = Set([ "com.wordpress.test.premium.1year", "com.wordpress.test.business.1year"])
    static let sharedInstance = StoreService()

    var request: SKProductsRequest? = nil
    var products: [SKProduct]? = nil
    var completionBlocks = [Completion]()

    func getProducts(completion: Completion) {
        if let products = self.products {
            completion(.Success(products))
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
            completion(.Success(response.products))
        }
        completionBlocks.removeAll()
    }

    func request(request: SKRequest, didFailWithError error: NSError) {
        for completion in completionBlocks {
            completion(.Failure(error))
        }
        completionBlocks.removeAll()
    }
}

class PlansListViewController: UITableViewController {
    // ...

    func fetchProducts() {
        StoreService.sharedInstance.getProducts { result in
            switch result {
            case .Success(let products):
                // Reload data showing products
            case .Failure(let error):
                // Show error
            }
        }
    }
}

class PlanDetailsViewController: UITableViewController {
    // ...

    func fetchProducts() {
        StoreService.sharedInstance.getProducts { result in
            switch result {
            case .Success(let products):
                // Reload data showing products
            case .Failure(let error):
                // Show error
            }
        }
    }
}


