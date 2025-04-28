import Foundation

public typealias ActionHandler = (Action?) -> Void

public enum ActionType: String,Decodable {
    case  form, discount, upsell, badge, information
}

public enum ActionPosition: String,Decodable {
    case center, topLeft, topRight, bottomLeft, bottomRight
}

public struct Action: Decodable {
    public let actionId: String?
    public let actionType:String?
    public let category: String?
    public let categoryId: String?
    public let promotionCode: String?
    public let custom: Bool?
    public let display: Display?
    public let html : String?
}

public struct Display: Decodable {
    public let paddle: Bool?
    public let position: String?
    public let fields:  Dictionary<String,DisplayField>?
    public let properties: Dictionary<String,DisplayProperty>?
    public let products: Dictionary<String, ProductResponse>?
}

public struct DisplayField: Decodable {
    public let name: String?
    public let text: String?
    public let color: String?
    public let url: String?
    public let position: String?
    public let textColor: String?
    public let styleResponse: StyleResponse?
}

public struct DisplayProperty: Decodable {
    public let propertyType: String?
    public let label: String?
    public let placeholder: String?
    public let required: String?
    public let options: Array<String>?
}

public struct StyleResponse: Decodable {
    public let textColor: String?
    public let backgroundColor: String?
    public let position: String?
    public let fontFamily: String?
    public let fontSize: String?
    public let fontWeight: String?
    public let textAlign: String?
    
}

public struct ProductResponse: Decodable {
    public let title:String?
    public let image: String?
    public let url: String?
    public let price: String?
    public let salesPrice: String?
    public let productPostCode: String?
}
