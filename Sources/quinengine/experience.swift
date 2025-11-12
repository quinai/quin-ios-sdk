//
//  experience.swift
//  quinengine
//
//  Created by Yusuf Erdogan on 21.10.2025.
//

public typealias ExperienceHandler = (Experience?) -> Void

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
