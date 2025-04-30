import Foundation

public struct Event: Encodable {
    public init(category: String,
                  action: String,
                  label: String = "",
                  url: String = "",
                  item: Item? = nil) {
        self.userId = ""
        self.token = ""
        self.googleClientId = ""
        self.platform = "ios"
        self.category = category
        self.action = action
        self.label = label
        self.url = url
        self.item = item
        self.customAttributes = [:]
    }
    
    private(set) public var userId: String
    private(set) public var token: String
    private(set) public var googleClientId: String
    public let platform: String
    public let category: String
    public let action: String
    public let label: String
    public let url: String
    public let item: Item?
    private(set) public var customAttributes : Dictionary<String,String>
    
    internal func setUser(user:User) -> Event {
        var newEvent = self
        newEvent.userId = user.id
        newEvent.token = user.token
        newEvent.googleClientId = user.googleClientId
        return newEvent
    }
    
    public func withCustomAttribute(key:String, value:String) -> Event {
        var customAttribute = self.customAttributes
        customAttribute[key] = value
        var newEvent = self
        newEvent.customAttributes = customAttribute
        return newEvent
    }
}

extension Event{
    public static let eCommerce = eCommerceEventImpl() as eCommerceEvent
}

enum EventCategory: String, Codable {
    case home,
         listing,
         detail,
         cart,
         checkout,
         service,
         interaction,
         reaction
}

enum EventLabel: String, Codable {
    case addtobasket,
         addtofavourites,
         productinfo,
         deliveryinfo,
         comments,
         quantity,
         gotocart,
         continueshopping,
         removefromcart,
         emptycart,
         checkout,
         login,
         discountcode,
         deliveryfee,
         adress,
         paymenttype,
         purchasecompleted
}

enum EventAction: String, Codable {
    case pageview,
         click
}

internal class eCommerceEventImpl : eCommerceEvent {
    func pageViewHomeEvent() -> Event{
        return Event(category:EventCategory.home.rawValue,
                     action: EventAction.pageview.rawValue)
    }
    func pageViewListingEvent(label:String) -> Event{
        return Event(category: EventCategory.listing.rawValue,
                     action: EventAction.pageview.rawValue,
                     label: label)
    }
    func pageViewListingWithCategoryIdEvent(label:String, categoryId: String) -> Event{
        return Event(category: EventCategory.listing.rawValue,
                     action: EventAction.pageview.rawValue,
                     label: label).withCustomAttribute(key: "categoryId", value: categoryId)
    }
    func addToCartListingEvent(item: Item, quantity: Int) -> Event{
        return Event(category: EventCategory.listing.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.addtobasket.rawValue,
                     item: item).withCustomAttribute(key: "quantity", value: quantity.description)
    }
    func filterEvent() -> Event{
        return Event(category: EventCategory.listing.rawValue,
                     action: EventAction.click.rawValue)
    }
    // Detail
    func pageViewDetailEvent(item: Item) -> Event{
        return Event(category: EventCategory.detail.rawValue,
                     action: EventAction.pageview.rawValue,
                     label: item.getCategory(),
                     item: item).withCustomAttribute(key: "categoryId", value: item.getCategoryId())
    }
    func addToCartDetailEvent(item: Item, quantity: Int) -> Event{
        return Event(category: EventCategory.detail.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.addtobasket.rawValue,
                     item: item).withCustomAttribute(key: "quantity", value: quantity.description)
    }
    func addToFavouritesEvent(item: Item) -> Event{
        return Event(category: EventCategory.detail.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.addtofavourites.rawValue,
                     item: item)
    }
    func productInfoEvent(item: Item) -> Event{
        return Event(category: EventCategory.detail.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.productinfo.rawValue,
                     item: item)
    }
    func deliveryInfoEvent(item: Item) -> Event{
        return Event(category: EventCategory.detail.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.deliveryinfo.rawValue,
                     item: item)
    }
    func commentsEvent() -> Event{
        return Event(category: EventCategory.detail.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.comments.rawValue)
    }
    func quantityDetailEvent(item: Item, quantity: Int) -> Event{
        return Event(category: EventCategory.detail.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.quantity.rawValue,
                     item: item).withCustomAttribute(key: "quantity", value: quantity.description)
    }
    // Cart
    func quantityCartEvent(item: Item, quantity: Int) -> Event{
        return Event(category: EventCategory.cart.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.quantity.rawValue,
                     item: item).withCustomAttribute(key: "quantity", value: quantity.description)
    }
    func goToCartEvent() -> Event{
        return Event(category: EventCategory.cart.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.gotocart.rawValue)
    }
    func continueShoppingEvent() -> Event{
        return Event(category: EventCategory.cart.rawValue,
                     action:  EventAction.click.rawValue,
                     label: EventLabel.continueshopping.rawValue)
    }
    func removeFromCartEvent(item: Item, quantity: Int) -> Event{
        return Event(category: EventCategory.cart.rawValue,
                     action: EventAction.click.rawValue,
                     label:  EventLabel.removefromcart.rawValue,
                     item: item).withCustomAttribute(key: "quantity", value: quantity.description)
    }
    func emptyCartEvent() -> Event{
        return Event(category: EventCategory.cart.rawValue,
                     action:  EventAction.click.rawValue,
                     label: EventLabel.emptycart.rawValue)
    }
    func checkoutEvent() -> Event{
        return Event(category: EventCategory.cart.rawValue,
                     action:  EventAction.click.rawValue,
                     label: EventLabel.checkout.rawValue)
    }
    func loginEvent() -> Event{
        return Event(category:"\(EventCategory.checkout)",
                     action: "\(EventAction.click)",
                     label: "\(EventLabel.login)")
    }
    func discountCodeEvent(discountCode: String) -> Event{
        return Event(category: EventCategory.checkout.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.discountcode.rawValue)
        .withCustomAttribute(key: "discountcode", value: discountCode)
    }
    func deliveryFeeEvent() -> Event{
        return Event(category:EventCategory.checkout.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.deliveryfee.rawValue)
    }
    func adressEvent() -> Event{
        return Event(category:EventCategory.checkout.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.adress.rawValue)
    }
    func paymentTypeEvent() -> Event{
        return Event(category:EventCategory.checkout.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.paymenttype.rawValue)
    }
    func purchaseCompletedEvent(totalBasketSize: Float) -> Event{
        return Event(category: EventCategory.checkout.rawValue,
                     action:  EventAction.click.rawValue,
                     label: EventLabel.purchasecompleted.rawValue)
        .withCustomAttribute(key: "totalbasketsize", value: totalBasketSize.description)
    }
    func addToCartServiceEvent(item: Item, quantity: Int) -> Event{
        return Event(category: EventCategory.service.rawValue,
                     action: EventAction.click.rawValue,
                     label: EventLabel.addtobasket.rawValue,
                     item: item).withCustomAttribute(key: "quantity", value: quantity.description)
    }
}


public protocol eCommerceEvent{
    func pageViewHomeEvent() -> Event
    func pageViewListingEvent(label:String) -> Event
    func pageViewListingWithCategoryIdEvent(label:String, categoryId: String) -> Event
    func addToCartListingEvent(item: Item, quantity: Int) -> Event
    func filterEvent() -> Event
    func pageViewDetailEvent(item: Item) -> Event
    func addToCartDetailEvent(item: Item, quantity: Int) -> Event
    func addToFavouritesEvent(item: Item) -> Event
    func productInfoEvent(item: Item) -> Event
    func deliveryInfoEvent(item: Item) -> Event
    func commentsEvent() -> Event
    func quantityDetailEvent(item: Item, quantity: Int) -> Event
    func quantityCartEvent(item: Item, quantity: Int) -> Event
    func goToCartEvent() -> Event
    func continueShoppingEvent() -> Event
    func removeFromCartEvent(item: Item, quantity: Int) -> Event
    func emptyCartEvent() -> Event
    func checkoutEvent() -> Event
    func loginEvent() -> Event
    func discountCodeEvent(discountCode: String) -> Event
    func deliveryFeeEvent() -> Event
    func adressEvent() -> Event
    func paymentTypeEvent() -> Event
    func purchaseCompletedEvent(totalBasketSize: Float) -> Event
    func addToCartServiceEvent(item: Item, quantity: Int) -> Event
}
