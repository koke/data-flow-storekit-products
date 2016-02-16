import UIKit
import Reachability
import RxSwift
import StoreKit

class StoreService: NSObject {
    class ProductRequestDelegate: NSObject, SKProductsRequestDelegate {
        typealias Success = [SKProduct] -> Void
        typealias Failure = ErrorType -> Void

        let onSuccess: Success
        let onError: Failure

        init(onSuccess: Success, onError: Failure) {
            self.onSuccess = onSuccess
            self.onError = onError
        }

        func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
            onSuccess(response.products)
        }

        func request(request: SKRequest, didFailWithError error: NSError) {
            onError(error)
        }
    }

    class ProductRequestDisposable: Disposable {
        let request: SKProductsRequest
        let delegate: SKProductsRequestDelegate

        init(request: SKProductsRequest, delegate: SKProductsRequestDelegate) {
            self.request = request
            self.delegate = delegate
        }

        func dispose() {
            request.cancel()
        }
    }
    static let identifiers = Set([ "com.wordpress.test.premium.1year", "com.wordpress.test.business.1year"])
    static let reachability = Reachability.internetConnection

    static var products: Observable<[SKProduct]> {
        return productsRequest
            .pausable(reachability)
            .shareReplayLatestWhileConnected()
    }

    static private var productsRequest: Observable<[SKProduct]> {
        return Observable.create { observer in
            let request = SKProductsRequest(productIdentifiers: identifiers)
            let delegate = ProductRequestDelegate(
                onSuccess: { products in
                    observer.onNext(products)
                }, onError: { error in
                    observer.onError(error)
            })
            request.delegate = delegate

            request.start()

            return ProductRequestDisposable(request: request, delegate: delegate)
        }
    }
}

class PlansListViewController: UITableViewController {
    // ...

    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        StoreService.products
            .subscribe(
                onNext: { products in
                    // Reload data showing products
                }, onError: { error in
                    // Show error
            })
            .addDisposableTo(bag)
    }
}

class PlanDetailsViewController: UITableViewController {
    // ...

    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        StoreService.products
            .subscribe(
                onNext: { products in
                    // Reload data showing products
                }, onError: { error in
                    // Show error
            })
            .addDisposableTo(bag)
    }
}


