

import Foundation

public typealias AuthenticationTokenProvider = (_ api: APIDefinition) -> String

/// An authentication plugin which prepares a request as per authentication strategy.
/// Reads token from authentication token provider.
public class AuthenticationPlugin: ServicePluginType {
    public let provider: AuthenticationTokenProvider

    public init(_ provider: @escaping AuthenticationTokenProvider) {
        self.provider = provider
    }

    public func mutate(_ request: URLRequest, api: APIDefinition) -> URLRequest {
        guard let authorizable = api as? AccessAuthorizable else { return request }
        var authenticatedRequest = request
        let authStrategy = authorizable.authenticationStrategy
        switch authStrategy {
        case .none:
            return request
        case .bearer:
            guard let scheme = authStrategy.scheme else { return authenticatedRequest }
            let token = provider(api)
            let value = "\(scheme) \(token)"
            authenticatedRequest.addValue(value, forHTTPHeaderField: "Authorization")
        case .bearerWithCustomHeaderField(let field):
            guard let scheme = authStrategy.scheme else { return authenticatedRequest }
            let token = provider(api)
            let value = "\(scheme) \(token)"
            authenticatedRequest.addValue(value, forHTTPHeaderField: field)
        case .customHeaderField(let field):
            let token = provider(api)
            authenticatedRequest.addValue(token, forHTTPHeaderField: field)
        }

        return authenticatedRequest
    }
}
