import Foundation

public typealias ResponseHandler = (Result<Response, Error>) -> Void


public  struct Response: Decodable {
    var content: Content?
    var message: String
    var responseCode: Int
}

public struct Content: Decodable {
    var userId: String
    var token: String
    var googleClientId : String?
    var interaction: Action?
    var experienceInteraction: Experience?
    func user() -> User {
        User(id: userId, token: token, googleClientId: googleClientId ?? "")
    }
}


