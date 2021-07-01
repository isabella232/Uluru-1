import Foundation
@testable import Uluru

enum PostmanEcho {
    case justGet
    case getWithParams(params: JSONRepresentable)
    case postWithBody(body: JSONRepresentable)
    case postBodyWithCustomEncoder(body: JSONRepresentable)
    case postWithoutBody
    case justGetWithPlaceholderData
    // returns supplied headers in response.
    case echoBearerAuth
    case echoBearerWithCustomHeaderAuth(headerName: String)
    case echoCustomHeaderAuth(headerName: String)
    case patch
    // dont exists
    case invalidRoute
}

extension PostmanEcho: APIDefinition, AccessAuthorizable {

    var baseURL: URL {
        return URL(string: "https://postman-echo.com")!
    }

    var path: String {
        switch self {
        case .getWithParams, .justGet, .justGetWithPlaceholderData:
            return "/get"

        case .echoBearerAuth, .echoBearerWithCustomHeaderAuth, .echoCustomHeaderAuth:
            return "/headers"

        case .postWithBody, .postBodyWithCustomEncoder, .postWithoutBody:
            return "/post"

        case .patch:
            return "/patch"

        case .invalidRoute:
            return "/godzillaIsAlive"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getWithParams, .justGet, .justGetWithPlaceholderData, .echoBearerAuth, .echoBearerWithCustomHeaderAuth, .echoCustomHeaderAuth, .invalidRoute:
            return .GET

        case .postWithBody, .postBodyWithCustomEncoder, .postWithoutBody:
            return .POST

        case .patch:
            return .PATCH
        }
    }

    var encoding: EncodingStrategy {
        switch self {
        case .justGet, .justGetWithPlaceholderData, .echoBearerAuth, .echoBearerWithCustomHeaderAuth, .echoCustomHeaderAuth, .invalidRoute:
            return .dontEncode
            
        case let .getWithParams(params):
            return .queryParameters(parameters: params)

        case .postWithBody(let body):
            return .jsonBody(parameters: body)

        case .postBodyWithCustomEncoder(let body):
            return .jsonBodyUsingCustomEncoder(parameters: body, encoder: CustomEncoder())

        case .postWithoutBody, .patch:
            return .dontEncode
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var placeholderData: Data? {
        switch self {
        case .justGetWithPlaceholderData:
            return try! JSONEncoder().encode(MockPlaceholder())
        default:
            return nil
        }
    }

    var authenticationStrategy: AuthenticationStrategy {
        switch self {
        case .echoBearerAuth:
            return .bearer
        case .echoBearerWithCustomHeaderAuth(let headerName):
            return .bearerWithCustomHeaderField(headerName)
        case .echoCustomHeaderAuth(let headerName):
            return .customHeaderField(headerName)
        default:
            return .none
        }
    }
}

struct MockPlaceholder: Codable, Equatable {
    let name = "This is placeholder data."
}

struct EmptyDecodableModel: Decodable {}

/// Contains reponse which echoes supplied headers.
/// https://docs.postman-echo.com/?version=latest#da16c006-6293-c1fe-ea42-e9ba8a5e68b1
struct EchoHeaders: Codable, Equatable, JSONRepresentable {
    let headers: [String: String]
}

struct EchoParams: Codable, Equatable, JSONRepresentable {
    let foo: String
    let bar: String

    static func make() -> EchoParams {
        return EchoParams(foo: "here", bar: "there")
    }
}

enum ErrorAPIDefinition {
    case thisDontExist
    case failParsing(params: JSONRepresentable)
    case invalidRoute
}

extension ErrorAPIDefinition: APIDefinition {
    var baseURL: URL {
        switch self {
        case .thisDontExist:
            return URL(string: "https://this-server-dont-exist.com")!
        default:
            return URL(string: "https://postman-echo.com")!
        }
    }

    var path: String {
        switch self {
        case .thisDontExist:
            return "/findMe"
        case .invalidRoute:
            return "anInvalidRoute"
        default:
            return "/get"
        }
    }

    var method: HTTPMethod {
        return .GET
    }

    var encoding: EncodingStrategy {
        switch self {
        case .thisDontExist, .invalidRoute:
            return .dontEncode
        case .failParsing(let params):
            return .queryParameters(parameters: params)
        }
    }

    var headers: [String : String]? {
        return nil
    }
}
