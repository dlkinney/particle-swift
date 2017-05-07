// This source file is part of the vakoc.com open source project(s)
//
// Copyright © 2017 Mark Vakoc. All rights reserved.
// Licensed under Apache License v2.0
//
// See http://www.vakoc.com/LICENSE.txt for license information

import Foundation

/// A Particle Product
public struct Product {
    
    /// The constants used to construct/parse from json
    fileprivate enum DictionaryConstants: String {
        case id
        case platformId = "platform_id"
        case name
        case slug
        case latestFirmwareVersion = "latest_firmware_version"
        case description
        case type
        case hardwareVersion = "hardware_version"
        case configId = "config_id"
        case organization
        case subscriptionId = "subscription_id"
        case mbLimit = "mb_limit"
    }
    
    /// The market segment the product is geard to
    ///
    /// - hobbyist: Hobbyists
    /// - consumer: Consumers
    /// - industrial: Industrial Uses
    public enum ProductType: String {
        case hobbyist = "Hobbyist"
        case consumer = "Consumer"
        case industrial = "Industrial"
    }
    
    /// Unique identifier for the product
    public var id: Int
    
    /// The device that is included in the product
    public var platform: DeviceInformation.Product

    /// The name of the product
    public var name: String
    
    /// The product slug
    public var slug: String
    
    /// The most recent firmware version, if availble
    public var latestFirmwareVersion: String?
    
    /// A description of the product
    public var description: String
    
    /// The type (marget segment) of the product
    public var type: ProductType
    
    /// The version of the hardware associated with the product
    public var hardwareVersion: String
    
    /// The product configuration identifier
    public var configId: String
    
    /// The organization that owns the product
    public var organization: String
    
    /// The product subscription identifier
    public var subscriptionId: Int
    
    /// Whether the product requires an activation code
    public var requiresActivationCodes: Bool = false
    
    /// The data limit imposed on the product
    public var mbLimit: Int?
}

extension Product: Equatable {
    public static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.platform == rhs.platform &&
            lhs.latestFirmwareVersion == rhs.latestFirmwareVersion &&
            lhs.description == rhs.description &&
            lhs.type == rhs.type &&
            lhs.hardwareVersion == rhs.hardwareVersion &&
            lhs.configId == rhs.configId &&
            lhs.organization == rhs.organization &&
            lhs.subscriptionId == rhs.subscriptionId &&
            lhs.subscriptionId == rhs.subscriptionId &&
            lhs.requiresActivationCodes == rhs.requiresActivationCodes &&
            lhs.mbLimit == rhs.mbLimit
    }
}

extension Product: StringKeyedDictionaryConvertible {
    
    ///  Create a Product with a dictionary
    ///
    /// The dictionary looks like the following
    ///
    ///        {
    ///          "id": 3699,
    ///          "platform_id": 6,
    ///          "name": "SampleProduct",
    ///          "slug": "sampleproduct-v101",
    ///          "latest_firmware_version": null,
    ///          "description": "A sample product",
    ///          "type": "Hobbyist",
    ///          "hardware_version": "v1.0.1",
    ///          "config_id": "58cc141a363e4e6f670d093a",
    ///          "organization": "58cc141a363e4e6f670d0938",
    ///          "subscription_id": 8573,
    ///          "mb_limit": null
    ///        }
    public init?(with dictionary: [String : Any]) {
        
        guard let productId = dictionary[DictionaryConstants.id.rawValue] as? Int,
            let platformId = dictionary[DictionaryConstants.platformId.rawValue] as? Int, let platform = DeviceInformation.Product(rawValue: platformId),
            let name = dictionary[DictionaryConstants.name.rawValue] as? String , !name.isEmpty,
            let slug = dictionary[DictionaryConstants.slug.rawValue] as? String,
            let type = dictionary[DictionaryConstants.type.rawValue] as? String, let productType = ProductType(rawValue: type),
            let hardwareVersion = dictionary[DictionaryConstants.hardwareVersion.rawValue] as? String,
            let configId = dictionary[DictionaryConstants.configId.rawValue] as? String,
            let organization = dictionary[DictionaryConstants.organization.rawValue] as? String,
            let subscriptionId = dictionary[DictionaryConstants.subscriptionId.rawValue] as? Int else {
                warn("Failed to create a Product using the dictionary \(dictionary);  the required properties were not found")
                return nil;
        }
        
        self.id = productId
        self.platform = platform
        self.name = name
        self.slug = slug
        self.type = productType
        self.latestFirmwareVersion = dictionary[DictionaryConstants.latestFirmwareVersion.rawValue] as? String
        self.hardwareVersion = hardwareVersion
        self.configId = configId
        self.organization = organization
        self.subscriptionId = subscriptionId
        description = dictionary[DictionaryConstants.description.rawValue] as? String ?? ""
        self.mbLimit = dictionary[DictionaryConstants.mbLimit.rawValue] as? Int
    }
    
    /// The product as a dictionary using keys compatible with the original web service
    public var dictionary: [String : Any] {
        get {
            var ret = [String : Any]()
            ret[DictionaryConstants.id.rawValue] = id
            ret[DictionaryConstants.platformId.rawValue] = platform.rawValue
            ret[DictionaryConstants.name.rawValue] = name
            ret[DictionaryConstants.slug.rawValue] = slug
            ret[DictionaryConstants.latestFirmwareVersion.rawValue] = latestFirmwareVersion
            ret[DictionaryConstants.description.rawValue] = description
            ret[DictionaryConstants.type.rawValue] = type.rawValue
            ret[DictionaryConstants.hardwareVersion.rawValue] = hardwareVersion
            ret[DictionaryConstants.configId.rawValue] = configId
            ret[DictionaryConstants.organization.rawValue] = organization
            ret[DictionaryConstants.subscriptionId.rawValue] = subscriptionId
            if let mbLimit = mbLimit {
                ret[DictionaryConstants.subscriptionId.rawValue] = mbLimit
            }
            return ret
        }
    }
}

/// A product team member
public struct ProductTeamMember {
    
    /// The constants used to construct/parse from json
    fileprivate enum DictionaryConstants: String {
        case id = "_id"
        case username
    }
    
    /// The unique identifier of the team memeber
    public var id: String
    
    /// Username of the team member
    public var username: String
}

extension ProductTeamMember: StringKeyedDictionaryConvertible {
    
    ///  Create a Product with a dictionary
    ///
    /// The dictionary looks like the following
    ///
    ///        [
    ///          {
    ///             "_id":"9980222caf8bad191600019b",
    ///             "username":"jeff@particle.io"
    ///          },
    ///          ...
    ///        ]
    public init?(with dictionary: [String : Any]) {
        
        guard let id = dictionary[DictionaryConstants.id.rawValue] as? String,
            let username = dictionary[DictionaryConstants.username.rawValue] as? String , !username.isEmpty else { return nil }

        self.id = id
        self.username = username
    }
    
    /// The dproduct as a dictionary using keys compatible with the original web service
    public var dictionary: [String : Any] {
        get {
            var ret = [String : Any]()
            ret[DictionaryConstants.id.rawValue] = id
            ret[DictionaryConstants.username.rawValue] = username
            return ret
        }
    }
}


extension ProductTeamMember: Equatable {
    
    public static func ==(lhs: ProductTeamMember, rhs: ProductTeamMember) -> Bool {
        return lhs.id == rhs.id && lhs.username == rhs.username
    }
}


/// A product team invitation
public struct ProductTeamInvitation {
    
    /// A product invitation
    public struct Invite {
        
        /// Unique organization identifier
        public var organization: String
        
        /// Product slug
        public var slug: String
        
        /// Product identifier
        public var product: String
        
        /// Product name
        public var name: String
        
        /// Invigation Originator
        public var invitedBy: String
        
        /// Invigation creation date
        public var invitedOn: Date
    }
    
    /// The constants used to construct/parse from json
    fileprivate enum DictionaryConstants: String {
        case id = "_id"
        case created = "created_at"
        case updated = "updated_at"
        case username
        case organizationInvites = "orgInvites"
        case organizations = "orgs"
        case organization = "org"
        case slug
        case invitedBy
        case invitedOn
        case product
        case name
    }
    
    /// The unique identifier of the team memeber
    public var id: String
    
    /// The creation date of the invitation
    public var created: Date
    
    /// The last modified date of the invitation
    public var updated: Date
    
    /// Username of the team member
    public var username: String
    
    /// Pending invitations to product teams
    public var organizationInvites = [Invite]()
    
    /// The product teams the to which user currently belongs.  TODO:  strongly type
    var organizations = [[String : Any]]()
}

extension ProductTeamInvitation.Invite: Equatable {
    public static func ==(lhs: ProductTeamInvitation.Invite, rhs: ProductTeamInvitation.Invite) -> Bool {
        return lhs.organization == rhs.organization &&
            lhs.slug == rhs.slug &&
            lhs.product == rhs.product &&
            lhs.name == rhs.name &&
            lhs.invitedBy == rhs.invitedBy &&
            lhs.invitedOn == rhs.invitedOn
    }
}

extension ProductTeamInvitation: StringKeyedDictionaryConvertible {
    
    ///  Create a Product with a dictionary
    ///
    /// The dictionary looks like the following
    ///
    ///      {
    ///        "_id":"12351fc561a46af606000abc",
    ///        "created_at":"2014-08-08T19:06:45.000Z",
    ///        "updated_at":"2017-03-14T22:38:40.028Z",
    ///        "username":"jeff.m.eiden@gmail.com",
    ///        "orgInvites": [
    ///          {
    ///            "org":"456bcd",
    ///            "slug":"my-product",
    ///            "product":"3333999",
    ///            "name":"My Product",
    ///            "invitedBy":"jeff@particle.io",
    ///            "invitedOn":"2017-01-18T18:53:00.235Z"
    ///          }
    ///        ],
    ///        "orgs":[]
    ///      }
    public init?(with dictionary: [String : Any]) {
        
        guard let id = dictionary[DictionaryConstants.id.rawValue] as? String,
            
            let createdString = dictionary[DictionaryConstants.created.rawValue] as? String, let created = createdString.dateWithISO8601String,
            let updatedString = dictionary[DictionaryConstants.created.rawValue] as? String, let updated = updatedString.dateWithISO8601String,
            let username = dictionary[DictionaryConstants.username.rawValue] as? String , !username.isEmpty else { return nil }
        
        self.id = id
        self.created = created
        self.updated = updated
        self.username = username
        
        if let orgInvites = dictionary[DictionaryConstants.organizationInvites.rawValue] as? [[String : Any]] {
            organizationInvites = orgInvites.flatMap {
                
                guard let organization = $0[DictionaryConstants.organization.rawValue] as? String,
                    let slug = $0[DictionaryConstants.slug.rawValue] as? String,
                    let product = $0[DictionaryConstants.product.rawValue] as? String,
                    let name = $0[DictionaryConstants.name.rawValue] as? String,
                    let invitedBy = $0[DictionaryConstants.invitedBy.rawValue] as? String,
                    let invitedOnString = $0[DictionaryConstants.invitedOn.rawValue] as? String,
                    let invitedOn = invitedOnString.dateWithISO8601String else { return nil }

                return Invite(organization: organization, slug: slug, product: product, name: name, invitedBy: invitedBy, invitedOn: invitedOn)
            }
        }
    }
    
    /// The dproduct as a dictionary using keys compatible with the original web service
    public var dictionary: [String : Any] {
        get {
            var ret = [String : Any]()
            ret[DictionaryConstants.id.rawValue] = id
            ret[DictionaryConstants.created.rawValue] = created.ISO8601String
            ret[DictionaryConstants.updated.rawValue] = updated.ISO8601String
            ret[DictionaryConstants.username.rawValue] = username
            
            let x: [[String : Any]] = organizationInvites.map {
                var ret = [String : Any]()
                ret[DictionaryConstants.organization.rawValue] = $0.organization
                ret[DictionaryConstants.slug.rawValue] = $0.slug
                ret[DictionaryConstants.product.rawValue] = $0.product
                ret[DictionaryConstants.name.rawValue] = $0.name
                ret[DictionaryConstants.invitedBy.rawValue] = $0.invitedBy
                ret[DictionaryConstants.invitedOn.rawValue] = $0.invitedOn.ISO8601String
                return ret
            }
            ret[DictionaryConstants.organizationInvites.rawValue] = x
            
            // TODO: handle orgs
            return ret
        }
    }
}

extension ProductTeamInvitation: Equatable {
    
    public static func ==(lhs: ProductTeamInvitation, rhs: ProductTeamInvitation) -> Bool {
        return lhs.id == rhs.id
            && lhs.created == rhs.created
            && lhs.updated == rhs.updated
            && lhs.username == rhs.username
            && lhs.organizationInvites == rhs.organizationInvites
            // TODO:  after strongly typing organizations add a check for equality
            //&& lhs.organizations == rhs.organizations
    }
}

// MARK: Products
extension ParticleCloud {
    
    /// List the available products or an individual product
    ///
    /// Reference API https://docs.particle.io/reference/api/#list-products
    ///
    /// - Parameters:
    ///   - productIdOrSlug: The product id (or slug) to retrieve.  If nil, all products will be retrieved
    ///   - completion: The asynchronous result containing an array of products or an error code
    public func products(_ productIdOrSlug: String? = nil, completion: @escaping (Result<[Product]>) -> Void ) {
        
        self.authenticate(false) { result in
            switch result {
                
            case .failure(let error):
                return completion(.failure(error))
                
            case .success(let accessToken):
                
                var url = self.baseURL.appendingPathComponent("v1/products")
                if let productIdOrSlug = productIdOrSlug {
                    url = url.appendingPathComponent("/\(productIdOrSlug)")
                }
                var request = URLRequest(url: url)
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                    
                    trace("Listing products", request: request, data: data, response: response, error: error)
                    
                    if let error = error {
                        return completion(.failure(ParticleError.productsListFailed(error)))
                    }
                    
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],  let j = json {
                        
                        if let products = j[productIdOrSlug == nil ? "products" : "product"] as? [[String : Any]] {
                            return completion(.success(products.flatMap({ return Product(with: $0)})))
                        } else {
                            return completion(.success([]))
                        }
                    } else {
                        
                        let message = data != nil ? String(data: data!, encoding: String.Encoding.utf8) ?? "" : ""
                        warn("Failed to obtain product with response: \(String(describing: response)) and message body \(String(describing: message))")
                        return completion(.failure(ParticleError.productsListFailed(ParticleError.httpResponseParseFailed(message))))
                    }
                }
                task.resume()
            }
        }
    }
    
    /// List all team members that are part of a given product
    ///
    /// Reference API https://docs.particle.io/reference/api/#list-team-members
    ///
    /// - Parameters:
    ///   - productIdOrSlug: The product id (or slug) to retrieve
    ///   - completion: The asynchronous result containing an array of products or an error code
    public func productTeamMembers(_ productIdOrSlug: String, completion: @escaping (Result<[ProductTeamMember]>) -> Void ) {
        
        self.authenticate(false) { result in
            switch result {
                
            case .failure(let error):
                return completion(.failure(error))
                
            case .success(let accessToken):
                
                let url = self.baseURL.appendingPathComponent("v1/products/\(productIdOrSlug)/team")
                var request = URLRequest(url: url)
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                    
                    trace("Retrieving product team members", request: request, data: data, response: response, error: error)
                    
                    if let error = error {
                        return completion(.failure(ParticleError.productTeamMembersFailed(error)))
                    }
                    
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]],  let j = json {
                        return completion(.success(j.flatMap({ return ProductTeamMember(with: $0)})))
                    } else {
                        
                        let message = data != nil ? String(data: data!, encoding: String.Encoding.utf8) ?? "" : ""
                        warn("Failed to obtain product team members with response: \(String(describing: response)) and message body \(String(describing: message))")
                        return completion(.failure(ParticleError.productTeamMembersFailed(ParticleError.httpResponseParseFailed(message))))
                    }
                }
                task.resume()
            }
        }
    }
    
    
    /// Invite a new member to a product team. Invitee will receive an email with a link to accept the invitation and join the team.
    ///
    /// Reference API https://docs.particle.io/reference/api/#invite-team-member
    ///
    /// - Parameters:
    ///   - productIdOrSlug: The product id (or slug) on which the invite is extended
    ///   - username: Username of the invitee. Must be a valid email associated with an Particle user
    ///   - completion: The asynchronous result containing details of the invited user or an error code
    public func inviteTeamMember(_ productIdOrSlug: String, username: String, completion: @escaping (Result<ProductTeamInvitation>) -> Void ) {
        
        self.authenticate(false) { result in
            switch result {
                
            case .failure(let error):
                return completion(.failure(error))
                
            case .success(let accessToken):
                
                let url = self.baseURL.appendingPathComponent("v1/products/\(productIdOrSlug)/team")
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = ["username" : username].URLEncodedParameters?.data(using: String.Encoding.utf8)

                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                    
                    trace("Inviting team member", request: request, data: data, response: response, error: error)
                    
                    if let error = error {
                        return completion(.failure(ParticleError.inviteTeamMemberFailed(error)))
                    }
                    
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],  let j = json, let invite = ProductTeamInvitation(with: j) {
                        return completion(.success(invite))
                    } else {                        
                        let message = data != nil ? String(data: data!, encoding: String.Encoding.utf8) ?? "" : ""
                        warn("Failed to invite team member with response: \(String(describing: response)) and message body \(String(describing: message))")
                        return completion(.failure(ParticleError.inviteTeamMemberFailed(ParticleError.httpResponseParseFailed(message))))
                    }
                }
                task.resume()
            }
        }
    }
    
    /// Remove a current team member.
    ///
    /// Reference API https://docs.particle.io/reference/api/#remove-team-member
    ///
    /// - Parameters:
    ///   - productIdOrSlug: The product id (or slug) on which the team member is removed
    ///   - username: Username of the team member to be removed
    ///   - completion: The asynchronous result detailing the result of the member removal
    public func removeTeamMember(_ productIdOrSlug: String, username: String, completion: @escaping (Result<Bool>) -> Void ) {
        
        self.authenticate(false) { result in
            switch result {
                
            case .failure(let error):
                return completion(.failure(error))
                
            case .success(let accessToken):
                guard let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                    return completion(.failure(ParticleError.invalidUsername))
                }
                
                let url = self.baseURL.appendingPathComponent("v1/products/\(productIdOrSlug)/team/\(encodedUsername)")
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                    
                    trace("Remove team member", request: request, data: data, response: response, error: error)
                    
                    if let error = error {
                        return completion(.failure(ParticleError.removeTeamMemberFailed(error)))
                    }
                    
                    if let response = response as? HTTPURLResponse, response.statusCode == 204 {
                        return completion(.success(true))
                    } else {
                        let message = data != nil ? String(data: data!, encoding: String.Encoding.utf8) ?? "" : ""
                        warn("Failed to remove team member with response: \(String(describing: response)) and message body \(String(describing: message))")
                        return completion(.failure(ParticleError.removeTeamMemberFailed(ParticleError.httpResponseParseFailed(message))))
                    }
                }
                task.resume()
            }
        }
    }
}





