import Foundation

struct LogConfiguration{
    var enableLogging : Bool?
}

struct HttpConfiguration {
    let url = "https://g.quinengine.com/api/v1/"
    var apiKey: String = ""
    var domain: String = ""
}
