# Quin Audience Engine iOS SDK

![image (1)](https://user-images.githubusercontent.com/112876992/222405013-487c28f7-5bfc-4265-8f0c-1b8a890101f7.png)

***

1. What is Quin Quin Audience Engine ?

Quin Audience Engine is a real-time digital customer analytics tool that helps e-commerce websites predict visitors' behavior after only 3-clicks, and engage them in real-time.

2. What is Quin Audience Engine iOS SDK ?

Quin Audience Engine iOS SDK is used to create and send events to the Quin AI backend. In result of tracked events, you will get actions.

***

## SETUP

Quin Audience Engine iOS SDK uses github for distribution. In order to add this library to your project first add it to your project dependencies by following lines. 

```swift
dependencies: [
    ...
    .package(url: "https://github.com/quinai/ios-sdk.git", from: <version-string>),
]
```

Then import it to your project by following lines.

```swift
import Quin
```

After importing the library you need to create a Quin object before sending events. In order to initialize an object:

```swift
let quin = Quin.getInstance() // with default queue
let quin = Quin.getInstace(queue: DispatchQueue(label: "your-label"))
```

After creating the object you need to initialize it before sending events. In order to initialize sdk first set configs and thens set the user with the following lines.

```swift
quin.setConfig(apiKey: "api-key", domain: "domain", enableLogging: false)
quin.setUser(googleClientId: "client-id") 
```

> enableLogging option is used to print logs to the console. 

After the initialization is done, you can start sending events.

***

## Structures

### Item
The item structure holds the information about the item such as name, category, price etc. Item class is sent inside event to give item information of that event. 

```swift
Item {
 id: String,
 name: String,
 category: String,
 categoryId: String,
 price: Decimal,
 currency: String,
}
```

Here is an example of Item creation.

```swift
Item(id: "1250353863",
 name: "wooden chair",
 category: "Garden",
 categoryId: "1002"
 price: 39.99,
 currency: "USD"
```

### Action
Action is the structure that tracker or send functions returns. Action holds the properties such as category, promotion code, display etc.
Resulted action which has the following structure can be used to show pop-ups on the screen.

```swift
Action {
    public let actionId: String?
    public let actionType:String?
    public let category: String?
    public let categoryId: String?
    public let promotionCode: String?
    public let custom: Bool?
    public let display: Display?
    public let html : String?
}
```

### Display
Display structure holds the actions display properties that is required to draw the pop-up.

```swift
Display {
    public let paddle: Bool?
    public let position: String?
    public let fields:  Dictionary<String,DisplayField>?
    public let properties: Dictionary<String,DisplayProperty>?
    public let products: Dictionary<String, ProductResponse>?
}
```

### DisplayField
DisplayField structure holds the field entity of an display object.

```swift
DisplayField {
    public let name: String?
    public let text: String?
    public let color: String?
    public let url: String?
    public let position: String?
    public let textColor: String?
    public let styleResponse: StyleResponse?
}
```

### DisplayProperty
DisplayProperty structure holds the property entity of an display object.

```swift
DisplayProperty {
    public let propertyType: String?
    public let label: String?
    public let placeholder: String?
    public let required: String?
    public let options: Array<String>?
}
```
### StyleResponse
StyleResponse {
    public let textColor: String?
    public let backgroundColor: String?
    public let position: String?
    public let fontFamily: String?
    public let fontSize: String?
    public let fontWeight: String?
    public let textAlign: String?
    
}

```
## Experience and Campaign

public struct Campaign: Decodable {
    public let paddle: Bool?
    public let position: String?
    public let contentType: String?
    public let code: String?
}

public struct Experience: Decodable {
    public let campaignContent: Campaign?
    public let type: String?
    public let promotionCode:String?
}

The `code` field within the campaign structure contains HTML code for the pop-up. You can display this HTML code using a `WebView` tool.

***

SDK allows us to send events and recieve actions in result. There are 2 ways to send events to the Quin AI's backend service which are using predefined send event functions and creating custom events and sending them manually. These sending functions take a completion parameter as type of ActionHandler which is simply:

```swift
typealias ActionHandler = (Action?) -> Void
public typealias ExperienceHandler = (Experience?) -> Void
```

You can pass completions to those functions and use resulted actions in your code.

### Sending Predefined events

In Quin we have a set of predefined event sender functions that require minimum set of data for the backend such as widely known e-commerce events.
Functions that send predefined events by Quin SDK are listed below.

```swift
sendTestEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendPageViewHomeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendPageViewListingEvent(label:String,completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendPageViewListingWithCategoryIdEvent(label:String, categoryId: String, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendAddToCartListingEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendFilterEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendPageViewDetailEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendAddToCartDetailEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendAddToFavouritesEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendProductInfoEvent(item:Item, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendCommentsEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendQuantityDetailEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendQuantityCartEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendGoToCartEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendContinueShoppingEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendRemoveFromCartEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendEmptyCartEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendCheckoutEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendLoginEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendDiscountCodeEvent(discountCode:String, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendDeliveryFeeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendAdressEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendPaymentTypeEvent(completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendPurchaseCompletedEvent(totalBasketSize:Float, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
sendAddToCartServiceEvent(item:Item, quantity: Int, completion:@escaping ActionHandler,experience: @escaping ExperienceHandler)
```

All predefined functions above are defined inside e-commerce interface to create an abstraction to users. You can simply send events from interface variable inside Quin singleton class. Following lines explain how to use them. 

```swift
quin.eCommerce().sendFilterEvent() { action in
    print(action ?? "action is nil")
}
```

### Sending Custom events

In order to send custom events first you need to create event to be sent. We have declared some event functions that returns widely known e-commerce events. These events are listed below. 

```swift
pageViewHomeEvent()
pageViewListingEvent(label: String)
pageViewListingWithCategoryIdEvent(label:String, categoryId: String)
addToCartListingEvent(item: Item?, quantity: Int)
filterEvent()
pageViewDetailEvent(item: Item)
addToCartDetailEvent(item: Item?, quantity: Int)
addToFavouritesEvent(item: Item?)
productInfoEvent(item: Item?)
deliveryInfoEvent(item: Item?)    
commentsEvent()
quantityDetailEvent(item: Item?, quantity: Int)
quantityCartEvent(item: Item?, quantity: Int)
goToCartEvent()
continueShoppingEvent()
removeFromCartEvent(item: Item?, quantity: Int)
emptyCartEvent()
checkoutEvent()
loginEvent()
discountCodeEvent(discountCode: String)
deliveryFeeEvent()
adressEvent()
paymentTypeEvent()
purchaseCompletedEvent(totalBasketSize: Int)
addToCartServiceEvent(item: Item?, quantity: Int)
```

All predefined functions above are defined inside e-commerce interface to create an abstraction to users. You can simply create events from interface variable inside Event class. Following lines explain how to use them. 

* Returns Event structure with filled with home pageview data.
```swift
let event = Event.eCommerce.pageViewHomeEvent()
```

* Takes item as Item struct and quantity as integer. Returns Event structure filled with add to cart, item, and quantity data.
> Item can be nil.
```swift
let event = Event.eCommerce.addToCartListingEvent(item: myItem, quantity: 2)
```

Also adding custom attributes to those events are possible by function ```withCustomAttribute(key: String, value: String)```. Following example shows how to use it.

```swift
val event = Event.eCommerce.pageViewHomeEvent().withCustomAttribute(key: "color", color: "red")
```

After creating the event you can send them to the Quin services using ```track(event: Event, completion:@escaping ActionHandler)```. Following line shows how to use it.

```swift
Quin quin = Quin.getInstance(queue: DispatchQueue)
let event = Event.eCommerce.pageViewHomeEvent()
quin.track(event: event) { action in
    print(action ?? "action is nil")
}
```

If those functions does not satisfy your use cases, you can create custom events and send them to Quin services again using track function. Following example demonstrates how to create custom events and send it. 

```swift
let item = Item("id", "name", "cat","cat-id", 5.00, "usd")
let event = Event(category : "\(EventCategory.home)",
                  action : "\(EventAction.click)", 
                  label : "custom label", 
                  url : "ex-screen", 
                  item : item)
quin.track(event = event) { action in
    print(action ?? "action is nil")
}
```

***

## Quick Start

After adding library to your project and setting up initialization, we have declared a test function that sends a test event to Quin services, and returns a mock Action filled with below data.


```swift
Action: {
    actionId:      "d3da1e3c5b1f8159",
    actionType:    "upsell",
    category:      "Garden > Storage > Storage Wardrobe",
    categoryId:    "10051-54541"
    promotionCode: "QTK1-4RSS-RR38-FTGR",
    custom:        false,
    display: {
        paddle:   true,
    position: "center",
        fields: {
            "actionButton": {
        Name:     "actionButton",
        Text:     "Copy",
        Color:    "#f59f1d",
        Url:      "",
        Position: "",
        },
            "dismissButton": {
        Name:     "dismissButton",
        Text:     "Close",
        Color:    "#ffffff",
        Url:      "",
        Position: "",
        },
        "image": {
        Name:     "image",
        Text:     "",
        Color:    "",
        Url:      "https://cdn.thequin.ai/act/20221221-efab69f589f50a1a62ae5d4a2c785e29.png",
        Position: "top",
        },
            "background": {
        Name:     "background",
        Text:     "",
        Color:    "#ffe8b3",
        Url:      "",
        Position: "",
        },
            "description": {
        Name:     "description",
        Text:     "Don't forget to use your %10 discount code. You can get a maximum discount of $100",
        Color:    "#000000",
        Url:      "",
        Position: "",
        }
        },
    properties: nil
    }
}
```


You can use this action as a reference and use it to draw pop-ups etc. In order to send test event you can use Quin singleton's ```test(event: Event, completion:@escaping ActionHandler)```function. Following lines shows how to do this.

```swift

let item = Item(
    id : "testId",
    name : "testName",
    category : "testCategory",
    categoryId: "test-category-id"
    price : 93.8,
    currency : "TRY")
val event = Event(
    category : "cat",
    action : "act",
    label : "lab",
    url : "ex-screen",
    item : item)
    .withCustomAttribute(key: "color", value: "blue")
quin.eCommerce().sendTestEvent(event: event) { action in
    // Use action variable here
}
```

***

## Troubleshooting

For any problems or further questions you can contact us with from hello@quinengine.com address.  

