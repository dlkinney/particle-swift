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
    public var mbLimit: Any?
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
        self.mbLimit = dictionary[DictionaryConstants.mbLimit.rawValue]
    }
    
    /// The dproduct as a dictionary using keys compatible with the original web service
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

/// Representation of a product team member
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
}





