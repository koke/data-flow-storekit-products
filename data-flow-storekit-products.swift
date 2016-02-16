import UIKit
import Reachability
import StoreKit

class StoreService: NSObject, SKProductsRequestDelegate {
    enum Result {
        case Success([SKProduct])
        case Failure(ErrorType)
    }

    typealias Next = (Result) -> Void
    typealias RequestToken = String
    let identifiers = Set([ "com.wordpress.test.premium.1year", "com.wordpress.test.business.1year"])
    static let sharedInstance = StoreService()

    var request: SKProductsRequest? = nil
    var products: [SKProduct]? = nil
    var nextBlocks = [RequestToken: Next]()
    var wantsRequest = false
    var reachable = true

    let reachability = Reachability.reachabilityForInternetConnection()

    override init() {
        super.init()
        reachability.reachableBlock = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.reachable = true
            if strongSelf.wantsRequest {
                strongSelf.fetchProducts()
            }
        }
        reachability.unreachableBlock = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.reachable = false
            if let request = strongSelf.request {
                strongSelf.wantsRequest = true
                request.cancel()
            }
            let error = NSError(domain: "StoreService", code: 0, userInfo: nil)
            strongSelf.sendAll(.Failure(error))
        }
        reachability.startNotifier()
    }

    deinit {
        reachability.stopNotifier()
    }

    func getProducts(next: Next) -> RequestToken? {
        if let products = self.products {
            next(.Success(products))
            return nil
        } else {
            fetchProducts()
            return appendNext(next)
        }
    }

    func cancelProductRequest(token: RequestToken) {
        nextBlocks.removeValueForKey(token)
        if nextBlocks.isEmpty {
            wantsRequest = false
            request?.cancel()
            request = nil
        }
    }

    func appendNext(next: Next) -> RequestToken {
        let uuid = NSUUID().UUIDString
        nextBlocks[uuid] = next
        return uuid
    }

    func fetchProducts() {
        guard self.request == nil else {
            return
        }
        guard reachable else {
            wantsRequest = true
            return
        }
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        request.start()
        self.request = request
    }

    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        products = response.products
        sendAll(.Success(response.products))
        nextBlocks.removeAll()
        self.request = nil
        wantsRequest = false
    }

    func request(request: SKRequest, didFailWithError error: NSError) {
        sendAll(.Failure(error))
        nextBlocks.removeAll()
        self.request = nil
        wantsRequest = false
    }

    func sendAll(result: Result) {
        for (_, next) in nextBlocks {
            next(result)
        }
    }
}

class PlansListViewController: UITableViewController {
    // ...

    var productRequest: StoreService.RequestToken? = nil

    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        if let productRequest = self.productRequest {
            StoreService.sharedInstance.cancelProductRequest(productRequest)
            self.productRequest = nil
        }
    }

    func fetchProducts() {
        productRequest = StoreService.sharedInstance.getProducts { result in
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

    var productRequest: StoreService.RequestToken? = nil

    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        if let productRequest = self.productRequest {
            StoreService.sharedInstance.cancelProductRequest(productRequest)
            self.productRequest = nil
        }
    }

    func fetchProducts() {
        productRequest = StoreService.sharedInstance.getProducts { result in
            switch result {
            case .Success(let products):
                // Reload data showing products
            case .Failure(let error):
                // Show error
            }
        }
    }
}


