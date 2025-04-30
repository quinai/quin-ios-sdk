import Foundation

enum HttpError: Error{
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int)
    case noData
}

struct Http {
    private static var configuration = HttpConfiguration()
    
    static let sharedInstance = Http()
    
    init() {
    }
    
    static func setConfig(apiKey: String, domain: String) {
        configuration.apiKey = apiKey
        configuration.domain = domain
    }
    
    func post(path: String, body: Data? = nil, completion: @escaping ResponseHandler) {
        guard let request = request(path: path, method: "POST", body: body) else{
            Logger.sharedInstance.log(msg:"quin http post: request error")
            completion(.failure(HttpError.invalidRequest))
            return
        }
        execute(request: request, completion: completion)
    }
    
    func get(path: String, completion: @escaping ResponseHandler) {
        guard let request = request(path: path, method:  "GET", body: nil) else{
            Logger.sharedInstance.log(msg:"quin http get: request error")
            completion(.failure(HttpError.invalidRequest))
            return
        }
        execute(request: request, completion: completion)
    }
    
    func request(path: String, method:String, body:Data?) -> URLRequest? {
        guard let url = URL(string: Http.configuration.url + path) else{
            Logger.sharedInstance.log(msg:"quin http request: url can not be retrieved")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            request.httpBody = body
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(Http.configuration.domain, forHTTPHeaderField: "Origin")
        request.addValue(Http.configuration.apiKey, forHTTPHeaderField: "X-Api-Key")
        Logger.sharedInstance.log(msg: request.url?.description ?? "")
        return request
    }
    
    func execute(request: URLRequest, completion: @escaping ResponseHandler) {
        URLSession.shared.dataTask(with: request){ data,response, error in
            if let error = error{
                Logger.sharedInstance.log(msg: "quin httpHandler: network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.sharedInstance.log(msg: "quin httpHandler: invalid response type")
                completion(.failure(HttpError.invalidResponse))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else{
                Logger.sharedInstance.log(msg: "quin httpHandler: error statusCode: \(httpResponse.statusCode)")
                completion(.failure(HttpError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            guard let data = data else{
                Logger.sharedInstance.log(msg: "quin httpHandler: data is nil")
                completion(.failure(HttpError.invalidResponse))
                return
            }
            do{
                let res = try JSONDecoder().decode(Response.self, from: data)
                Logger.sharedInstance.log(msg: "quin response: \(res)")
                completion(.success(res))
            }catch{
                Logger.sharedInstance.log(msg:  "quin httpHandler: decode error: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
        }.resume()
    }
    
}
