import Foundation

/// Defines the authentication strategy
public enum AuthenticationStrategy {
    /// Authentication not required.
    case none

    /// Authentication with bearer scheme - `"Authorization": "Bearer <your token>"`
    case bearer
    
    /// Authentication with bearer scheme and custom header field - `"customHeaderField": "Bearer <your token>"`
    case bearerWithCustomHeaderField(String)

    /// Authentication with custom header field - `"MyAmazingToken": "<your token>"`
    case customHeaderField(String)
    
    var scheme: String? {
        switch self {
        case .none, .customHeaderField:
            return nil
        case .bearer, .bearerWithCustomHeaderField:
            return "Bearer"
        }
    }
}

/// Protocol to express API needs authentication.
public protocol AccessAuthorizable {
    var authenticationStrategy: AuthenticationStrategy { get }
}

