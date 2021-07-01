import Foundation
import Quick
import Nimble
@testable import Uluru


class AuthenticationPluginSpec: QuickSpec {
    override func spec() {
        TestHelper.markWaitExpecationAsAPIRequest()
        let ourToken = "our-token"
        let authProvider: AuthenticationTokenProvider = { api in
            return ourToken
        }

        context("When using .none strategy") {
            let service = ServiceRequester<PostmanEcho>(plugins: [AuthenticationPlugin(authProvider)])
            var actual: EchoHeaders!

            it("should not add any auth headers") {
                waitUntil { done in
                    let _ = service.request(.justGet, expecting: EchoHeaders.self, completion: { (result) in
                        actual = try! result.get().parsed
                        done()
                    })
                }
                expect(actual.headers["authorization"]).to( beNil() )
            }
        }

        context("When using .bearer strategy") {
            let service = ServiceRequester<PostmanEcho>(plugins: [AuthenticationPlugin(authProvider)])
            var actual: EchoHeaders!

            it("should add Authorization header with provided token") {
                waitUntil { done in
                    let _ = service.request(.echoBearerAuth, expecting: EchoHeaders.self, completion: { (result) in
                        actual = result.forceGetParsed(EchoHeaders.self)
                        done()
                    })
                }
                expect(actual.headers["authorization"]).to( equal("Bearer \(ourToken)") )
            }
        }
        
        context("When using .bearerWithCustomHeaderField strategy") {
            let ourCustomHeader = "our-custom-header"
            let service = ServiceRequester<PostmanEcho>(plugins: [AuthenticationPlugin(authProvider)])
            var actual: EchoHeaders!

            it("should add Custom Field header with provided token") {
                waitUntil { done in
                    let _ = service.request(.echoBearerWithCustomHeaderAuth(headerName: ourCustomHeader), expecting: EchoHeaders.self, completion: { (result) in
                        actual = result.forceGetParsed(EchoHeaders.self)
                        done()
                    })
                }
                expect(actual.headers[ourCustomHeader]).to( equal("Bearer \(ourToken)") )
            }
        }

        context("When using .customHeaderField strategy") {
            let ourCustomHeader = "our-custom-header"
            let service = ServiceRequester<PostmanEcho>(plugins: [AuthenticationPlugin(authProvider)])
            var actual: EchoHeaders!

            it("request header contains custom header field with provided token value") {
                waitUntil { done in
                    let _ = service.request(.echoCustomHeaderAuth(headerName: ourCustomHeader), expecting: EchoHeaders.self, completion: { (result) in
                        actual = result.forceGetParsed(EchoHeaders.self)
                        done()
                    })
                }
                expect(actual.headers[ourCustomHeader]).to( equal(ourToken) )
            }
        }

    }
}
