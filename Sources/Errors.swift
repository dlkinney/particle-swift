// This source file is part of the vakoc.com open source project(s)
//
// Copyright © 2016, 2017 Mark Vakoc. All rights reserved.
// Licensed under Apache License v2.0
//
// See http://www.vakoc.com/LICENSE.txt for license information

import Foundation

/// Errors that can be thrown during particle operations
public enum ParticleError: Error {
    case missingCredentials,
    listAccessTokensFailed(Error),
    callFunctionFailed(Error),
    deviceListFailed(Error),
    deviceDetailedInformationFailed(Error),
    deviceInformationFailed(String, Error),
    oauthTokenCreationFailed(Error),
    oauthTokenParseFailed,
    oauthTokenDeletionFailed(Error),
    invalidURLRequest(Error),
    claimDeviceFailed(Error),
    transferDeviceFailed(Error),
    createClaimCode(Error),
    unclaimDeviceFailed(Error),
    webhookListFailed(Error),
    webhookGetFailed(String,Error),
    createWebhookFailed(Error),
    failedToParseJsonFile,
    deleteWebhookFailed(String,Error),
    httpResponseParseFailed(String?),
    variableValueFailed(Error),
    compileRequestFailed(String),
    librariesRequestFailed(String),
    librariesUrlMalformed(String),
    libraryVersionsRequestFailed(String),
    productsListFailed(Error),
    productTeamMembersFailed(Error),
    inviteTeamMemberFailed(Error),
    removeTeamMemberFailed(Error),
    invalidUsername,
    downloadBinaryFailed(Error),
    downloadError,
    flashDeviceFailed(Error),
    invalidToken,
    particleError(String, String),
    genericError
}

// Linux doesn't support variadic lists including strings, reference https://bugs.swift.org/browse/SR-957

#if os(Linux)
    
extension ParticleError: CustomStringConvertible {
    
    public var description: String {
        switch (self) {
        case .missingCredentials:
            return "Missing username or password credentials"
        case .listAccessTokensFailed(let error):
            return "The request to list available access tokens failed with error: \(error)"
        case .callFunctionFailed(let error):
            return "The request to call the function afiled with error: \(error)"
        case .deviceListFailed(let error):
            return "The request to obtain available devices failled with error: \(error)"
        case .deviceInformationFailed(let deviceID, let error):
            return "The request to obtain device information for device ID \(deviceID) failed with error: \(error)"
        case .deviceDetailedInformationFailed(let error):
            return "The request to obtain detailed device information failed with error: \(error)"
        case .oauthTokenCreationFailed(let error):
            return "Failed to create an OAuth token with error: \(error)"
        case .oauthTokenDeletionFailed(let error):
            return "Failed to delete an OAuth token with error: \(error)"
        case .oauthTokenParseFailed:
            return "The HTTP response could not be parsed as a valid token"
        case .invalidURLRequest(let error):
            return "Failed to create a valid URL request with error: \(error)"
        case .claimDeviceFailed(let error):
            return "Failed to claim device with error: \(error)"
        case .transferDeviceFailed(let error):
            return "Failed to transfer device with error: \(error)"
        case .createClaimCode(let error):
            return "Failed to create a claim code with error: \(error)"
        case .unclaimDeviceFailed(let error):
            return "Failed to unclaim a device with error: \(error)"
        case .webhookListFailed(let error):
            return "Failed to list the available webhooks with error: \(error)"
        case .webhookGetFailed(let webhookID, let error):
            return "Failed to get the webhook \(webhookID) with error: \(error)"
        case .createWebhookFailed(let error):
            return "Failed to create the webhook with error: \(error)"
        case .failedToParseJsonFile:
            return "Failed to parse the specified JSON file"
        case .deleteWebhookFailed(let webhookID, let error):
            return "Failed to delete the webhook \(webhookID) with error: \(error)"
        case .httpResponseParseFailed(let message):
            return "Failed to parse the HTTP response '\(message ?? "")'"
        case .variableValueFailed(let error):
            return "Failed to obtain variable value with error: \(error)"
        case .compileRequestFailed(let message):
            return "Failed to compile source files value with response \(message)"
        case .librariesRequestFailed(let error):
            return "Failed to obtain the available libraries with error: \(error)"
        case .librariesUrlMalformed(let string):
            return "Failed to construct a valid url for the libraries api using \(string)"
        case .libraryVersionsRequestFailed(let string):
            return "Failed to obtain library versions with error \(string)"
        case .productsListFailed(let error):
            return "Failed to list the products with error: \(error)"
        case .productTeamMembersFailed(let error):
            return "Failed to obtain the product team members with error: \(error)"
        case .inviteTeamMembeFailed(let error):
            return "Failed to invite team member with error: \(error)"
        case .removeTeamMemberFailed(let error):
            return "Failed to remove team member with error: \(error)"
        case .invalidUsername:
            return "Invalid Username"
        case .downloadBinaryFailed(let error):
            return "Failed to download binary with error: \(error)"
        case .downloadError:
            return "Failed to download binary"
        case .flashDeviceFailed(let error):
            return "Failed to flash device with error: \(error)"
        case .invalidToken:
            return "Failed to complete request due to an invalid token"
        case .particleError(let errorCode, let errorDescription):
            return "Received the error \(errorCode): \(errorDescription)"
        case .genericError:
            return "An unexpected error occurred"
        }
    }
}
    
#else
    
extension ParticleError: CustomStringConvertible {
    
    public var description: String {
        switch (self) {
        case .missingCredentials:
            return String.localizedStringWithFormat("Missing username or password credentials")
        case .listAccessTokensFailed(let error):
            return String.localizedStringWithFormat("The request to list available access tokens failed with error: %1@", "\(error)")
        case .callFunctionFailed(let error):
            return String.localizedStringWithFormat("The request to call the function afiled with error: %1@", "\(error)")
        case .deviceListFailed(let error):
            return String.localizedStringWithFormat("The request to obtain available devices failled with error: %1@", "\(error)")
        case .deviceInformationFailed(let deviceID, let error):
            return String.localizedStringWithFormat("The request to obtain device information for device ID %1@ failed with error %2@", deviceID, "\(error)")
        case .deviceDetailedInformationFailed(let error):
            return String.localizedStringWithFormat("The request to obtain detailed device information failed with error: %1@", "\(error)")
        case .oauthTokenCreationFailed(let error):
            return String.localizedStringWithFormat("Failed to create an OAuth token with error: %1@", "\(error)")
        case .oauthTokenDeletionFailed(let error):
            return "Failed to delete an OAuth token with error: \(error)"            
        case .oauthTokenParseFailed:
            return String.localizedStringWithFormat("The HTTP response could not be parsed as a valid token")
        case .invalidURLRequest(let error):
            return String.localizedStringWithFormat("Failed to create a valid URL request with error: %1@", "\(error)")
        case .claimDeviceFailed(let error):
            return String.localizedStringWithFormat("Failed to claim device with error: %1@", "\(error)")
        case .transferDeviceFailed(let error):
            return String.localizedStringWithFormat("Failed to transfer device with error: %1@", "\(error)")
        case .createClaimCode(let error):
            return String.localizedStringWithFormat("Failed to create a claim code with error: %1@", "\(error)")
        case .unclaimDeviceFailed(let error):
            return String.localizedStringWithFormat("Failed to unclaim a device with error: %1@", "\(error)")
        case .webhookListFailed(let error):
            return String.localizedStringWithFormat("Failed to list the available webhooks with error: %1@", "\(error)")
        case .webhookGetFailed(let webhookID, let error):
            return String.localizedStringWithFormat("Failed to get the webhook %1@ with error %2@", "\(webhookID)", "\(error)")
        case .createWebhookFailed(let error):
            return String.localizedStringWithFormat("Failed to create the webhook with error: %1@", "\(error)")
        case .failedToParseJsonFile:
            return String.localizedStringWithFormat("Failed to parse the specified JSON file")
        case .deleteWebhookFailed(let webhookID, let error):
            return String.localizedStringWithFormat("Failed to delete the webhook %1@ with error %2@", "\(webhookID)", "\(error)")
        case .httpResponseParseFailed(let message):
            return String.localizedStringWithFormat("Failed to parse the HTTP response '%1@'", message ?? "")
        case .variableValueFailed(let error):
            return String.localizedStringWithFormat("Failed to obtain variable value with error: %1@", "\(error)")
        case .compileRequestFailed(let message):
            return String.localizedStringWithFormat("Failed to compile source files value with response %1@", "\(message)")
        case .librariesRequestFailed(let error):
            return String.localizedStringWithFormat("Failed to obtain the available libraries with error: %1@", String(describing: error))
        case .librariesUrlMalformed(let string):
            return String.localizedStringWithFormat("Failed to construct a valid url for the libraries api using %1@", string)
        case .libraryVersionsRequestFailed(let string):
            return String.localizedStringWithFormat("Failed to obtain library versions with error: %1@", String(describing: string))
        case .productsListFailed(let error):
            return String.localizedStringWithFormat("Failed to list the products with error: %1@", String(describing: error))
        case .productTeamMembersFailed(let error):
            return String.localizedStringWithFormat("Failed to obtain the product team members with error: %1@", String(describing: error))
        case .inviteTeamMemberFailed(let error):
            return String.localizedStringWithFormat("Failed to invite team member with error: %1@", String(describing: error))
        case .removeTeamMemberFailed(let error):
            return String.localizedStringWithFormat("Failed to remove team member with error: %1@", String(describing: error))
        case .invalidUsername:
            return String.localizedStringWithFormat("Invalid username")
        case .downloadBinaryFailed(let error):
            return String.localizedStringWithFormat("Failed to download binary with error: %1@", String(describing: error))
        case .downloadError:
            return String.localizedStringWithFormat("Failed to download binary")
        case .flashDeviceFailed:
            return String.localizedStringWithFormat("Failed to flash device with error: %1@", String(describing: error))
        case .invalidToken:
            return String.localizedStringWithFormat("Failed to complete request due to an invalid token")
        case .particleError(let errorCode, let errorDescription):
            return String.localizedStringWithFormat("Received the error %1@: %2@", errorCode, errorDescription)
        case .genericError:
            return String.localizedStringWithFormat("An unexpected error occurred")
        }
    }
}
    
    
#endif
