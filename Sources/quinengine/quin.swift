import Foundation
/// Main SDK class for interaction with Quin Engine
public class Quin {
    public static let pathSession = "session"
    public static let pathEvent = "event"
    public static let pathTestEvent = "test-event"
    
    private let queue: DispatchQueue
    
    private static var instance: Quin?
    private static let lock = NSLock()
    /// Returns the shared singleton instance of Quin
    /// - Parameter queue: Optional DispatchQueue for event tracking operations (defaults to background queue).
    /// - Returns: A shared instance of Quin
    public static func getInstance(queue: DispatchQueue = DispatchQueue(label: "com.quinengine")) -> Quin{
        lock.lock()
        defer {lock.unlock()}
        if instance == nil{
            instance = Quin(queue: queue)
        }
        return instance!
    }
    
    private init(queue: DispatchQueue){
        self.queue = queue
    }
    
    /// Sets configuration parameters for API usage
    /// - Parameters:
    ///     - apiKey: The API key provided by Quin,
    ///     - domain: The domain (origin) for request validation
    ///     - enableLogging: Enables or disables debug logging
    public func setConfig(apiKey: String, domain: String, enableLogging: Bool = false){
        Http.setConfig(apiKey: apiKey, domain: domain)
        Logger.setConfig(enableLogging: enableLogging)
    }
    
    /// Sets the Google Client ID for the user sessions.
    /// - Parameter googleClientId: A valid Google Client ID string.
    public func setUser(googleClientId: String) {
        _ = self.user(googleClientId: googleClientId)
    }
    
    /// Tracks an event by sending it to the server.
    /// - Parameters:
    ///   - event: The event to track.
    ///   - path: The endpoint path for event submission (default is `event`).
    ///   - completion: Callback with the resulting `Action?` from the server response.
    public func track(event:Event, path: String = pathEvent, completion: @escaping ActionHandler, experience: @escaping ExperienceHandler){
        queue.async {
            guard let user = self.user() else{
                Logger.sharedInstance.log(msg: "quin track: user is nil")
                completion(nil)
                return
            }
            let req = event.setUser(user: user)
            guard let httpBody = try? JSONEncoder().encode(req) else{
                Logger.sharedInstance.log(msg: "quin track: encode error")
                completion(nil)
                return
            }
            Http.sharedInstance.post(path: path, body: httpBody){result in
                switch result {
                case .success(let response):
                    self.saveUser(response: response)
                    completion(response.content?.interaction)
                    experience(response.content?.experienceInteraction)
                case .failure(let error):
                    Logger.sharedInstance.log(msg: "quin track: network error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
            
        }
    }
    private func user(googleClientId: String? = nil) -> User?{
        var result: User?
        let semaphore = DispatchSemaphore(value: 0)
        
        if UserStore.sharedInstance.load() == nil{
            Http.sharedInstance.post(path: Quin.pathSession, body: nil){ postResult  in
                switch postResult {
                case .success(let response):
                    self.saveUser(response: response, googleClientId: googleClientId)
                case .failure(let error):
                    Logger.sharedInstance.log(msg: "quin user session: network error: \(error.localizedDescription)")
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
        result = UserStore.sharedInstance.load()
        return result
    }
    
    private func saveUser(response: Response, googleClientId: String? = nil){
        guard let user = response.content?.user() else {
            Logger.sharedInstance.log(msg: "quin saveUser: response user is nil")
            return
        }
        var modifiedUser = user
        if let id = googleClientId {
            modifiedUser = user.withGoogleClientId(googleClientId: id)
        }
        UserStore.sharedInstance.save(user: modifiedUser)
    }
    
    private lazy var eCommerceImpl: ECommerceImpl = ECommerceImpl(instance: self)
    
    public func eCommerce() -> eCommerce {
        return eCommerceImpl
    }
    
    
}


public protocol eCommerce{
    func sendTestEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendPageViewHomeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendPageViewListingEvent(label:String,completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendPageViewListingWithCategoryIdEvent(label:String, categoryId: String, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendAddToCartListingEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendFilterEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendPageViewDetailEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendAddToCartDetailEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendAddToFavouritesEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendProductInfoEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendCommentsEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendQuantityDetailEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendQuantityCartEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendGoToCartEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendContinueShoppingEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendRemoveFromCartEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendEmptyCartEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendCheckoutEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendLoginEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendDiscountCodeEvent(discountCode:String, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendDeliveryFeeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendAdressEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendPaymentTypeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendPurchaseCompletedEvent(totalBasketSize:Float, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
    func sendAddToCartServiceEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
}

internal class ECommerceImpl: eCommerce{
    private let instance: Quin
    
    init(instance: Quin) {
        self.instance = instance
    }
    
    public func sendTestEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.pageViewHomeEvent(), path: Quin.pathTestEvent, completion: completion, experience: experience)
    }
    public func sendPageViewHomeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.pageViewHomeEvent(), completion: completion, experience: experience)
    }
    public func sendPageViewListingEvent(label:String, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.pageViewListingEvent(label: label), completion: completion, experience: experience)
    }
    public func sendPageViewListingWithCategoryIdEvent(label:String, categoryId:String, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.pageViewListingWithCategoryIdEvent(label: label, categoryId: categoryId), completion: completion, experience: experience)
    }
    public func sendAddToCartListingEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.addToCartListingEvent(item: item, quantity: quantity), completion: completion, experience: experience)
    }
    public func sendFilterEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.filterEvent(), completion: completion, experience: experience)
    }
    public func sendPageViewDetailEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.pageViewDetailEvent(item:item), completion: completion, experience: experience)
    }
    public func sendAddToCartDetailEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.addToCartDetailEvent(item: item, quantity: quantity), completion: completion, experience: experience)
    }
    public func sendAddToFavouritesEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.addToFavouritesEvent(item:item), completion: completion, experience: experience)
    }
    public func sendProductInfoEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.productInfoEvent(item: item), completion: completion, experience: experience)
    }
    public func sendCommentsEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.commentsEvent(), completion: completion, experience: experience)
    }
    public func sendQuantityDetailEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.quantityDetailEvent(item: item, quantity: quantity), completion: completion, experience: experience)
    }
    public func sendQuantityCartEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.quantityCartEvent(item: item, quantity: quantity), completion: completion, experience: experience)
    }
    public func sendGoToCartEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.goToCartEvent(), completion: completion, experience: experience)
    }
    public func sendContinueShoppingEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.continueShoppingEvent(), completion: completion, experience: experience)
    }
    public func sendRemoveFromCartEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.removeFromCartEvent(item: item, quantity: quantity), completion: completion, experience: experience)
    }
    public func sendEmptyCartEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.emptyCartEvent(), completion: completion, experience: experience)
    }
    public func sendCheckoutEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.checkoutEvent(), completion: completion, experience: experience)
    }
    public func sendLoginEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.loginEvent(), completion: completion, experience: experience)
    }
    public func sendDiscountCodeEvent(discountCode:String, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.discountCodeEvent(discountCode: discountCode), completion: completion, experience: experience)
    }
    public func sendDeliveryFeeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.deliveryFeeEvent(), completion: completion, experience: experience)
    }
    public func sendAdressEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.adressEvent(), completion: completion, experience: experience)
    }
    public func sendPaymentTypeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.paymentTypeEvent(), completion: completion, experience: experience)
    }
    public func sendPurchaseCompletedEvent(totalBasketSize:Float, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.purchaseCompletedEvent(totalBasketSize: totalBasketSize), completion: completion, experience: experience)
    }
    public func sendAddToCartServiceEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler){
        instance.track(event: Event.eCommerce.addToCartServiceEvent(item: item, quantity: quantity), completion: completion, experience: experience)
    }
}
