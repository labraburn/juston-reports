//
//  WKWeb3Configuration.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation
import HuetonCORE
import WebKit

final class WKWeb3Configuration: WKWebViewConfiguration {
    
    private var events: [String : WKWeb3EventBox] = [
        WKWeb3EventBox(WKWeb3RequestAccountsEvent.self),
        WKWeb3EventBox(WKWeb3RequestWalletsEvent.self),
        WKWeb3EventBox(WKWeb3BalanceEvent.self),
        WKWeb3EventBox(WKWeb3SendTransactionEvent.self),
        WKWeb3EventBox(WKWeb3SignEvent.self),
        WKWeb3EventBox(WKWeb3UndefinedEvent.self),
    ].reduce(into: [:], { events, box in
        box.names.forEach({ events[$0] = box })
    })
    
    weak var dispatcher: WKWeb3EventDispatcher?
    
    var account: PersistenceAccount? {
        didSet {
            let accounts: [PersistenceAccount]
            if let account = account {
                accounts = [account]
            } else {
                accounts = []
            }
            
            Task {
                await emit(
                    value: WKWeb3AccountsChangedEmit(
                        accounts: accounts
                    )
                )
            }
        }
    }
    
    override init() {
        super.init()
        load()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func load() {
        guard let fileURL = Bundle.main.url(forResource: "hueton", withExtension: "js"),
              let string = try? String(contentsOf: fileURL)
        else {
            fatalError("[WKWeb3Configuration]: Can't being happend.")
        }
        
        let script = WKUserScript(
            source: string,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        let controller = WKUserContentController()
        controller.addUserScript(script)
        
        events.forEach({
            controller.add(self, name: $0.key)
        })
        
        userContentController = controller
        
        processPool = WKProcessPool()
        websiteDataStore = WKWebsiteDataStore.nonPersistent()
    }
}

extension WKWeb3Configuration {

    private struct BodyEmit: Encodable {
        
        let name: String
        let body: Data
    }
    
    private struct BodyRequest: Decodable {
        
        let id: String
        let method: String
        let request: Data
    }
    
    private struct ResponseResult: Encodable {

        let id: String
        let result: Data
    }
    
    private struct ResponseError: Encodable {

        let id: String
        let error: WKWeb3Error
    }
    
    private func emit<T>(
        value: T
    ) async where T: WKWeb3Emit {
        for name in T.names {
            let body = try? WKWeb3Configuration.encoder.encode(value)
            guard let body = body
            else {
                fatalErrorIfNeeded()
                return
            }
            
            let _emit = BodyEmit(
                name: name,
                body: body
            )
            
            let data = try? WKWeb3Configuration.encoder.encode(_emit)
            guard let data = data,
                  let message = String(data: data, encoding: .utf8)
            else {
                fatalErrorIfNeeded()
                return
            }
            
            await emit(
                message: message
            )
        }
    }
    
    private func respond(
        with result: ResponseResult
    ) async {
        let data = try? WKWeb3Configuration.encoder.encode(result)
        guard let data = data,
              let message = String(data: data, encoding: .utf8)
        else {
            fatalErrorIfNeeded()
            return
        }
        
        await respond(
            with: message
        )
    }
    
    private func respond(
        with error: ResponseError
    ) async {
        let message: String
        do {
            let data = try WKWeb3Configuration.encoder.encode(error)
            guard let string = String(data: data, encoding: .utf8)
            else {
                throw WKError(.unknown)
            }
            message = string
        } catch {
            message = "undefined"
        }
        
        await respond(
            with: message
        )
    }
    
    private func emit(
        message: String
    ) async {
        try? await dispatcher?.dispatch(
            name: "WKWeb3EventEmit",
            detail: message
        )
    }
    
    private func respond(
        with message: String
    ) async {
        try? await dispatcher?.dispatch(
            name: "WKWeb3EventResponse",
            detail: message
        )
    }
    
    private func fatalErrorIfNeeded() {
        #if DEBUG
        fatalError("Can't being happend.")
        #endif
    }
}

extension WKWeb3Configuration: WKScriptMessageHandler {
    
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let body: BodyRequest
        do {
            let data = try JSONSerialization.data(withJSONObject: message.body, options: .fragmentsAllowed)
            body = try WKWeb3Configuration.decoder.decode(BodyRequest.self, from: data)
        } catch {
            return
        }
        
        Task { @MainActor [weak self] in
            guard let type = events[message.name]
            else {
                await self?.respond(
                    with: ResponseError(id: body.id, error: WKWeb3Error(.unsupportedMethod))
                )
                return
            }
            
            guard let context = self?.dispatcher?.presentationContext,
                  let url = self?.dispatcher?.url
            else {
                await self?.respond(
                    with: ResponseError(id: body.id, error: WKWeb3Error(.disconnected))
                )
                return
            }
            
            do {
                await self?.respond(
                    with: ResponseResult(
                        id: body.id,
                        result: try await type.process(
                            self?.account,
                            context,
                            url,
                            body.request,
                            WKWeb3Configuration.decoder,
                            WKWeb3Configuration.encoder
                        )
                    )
                )
            } catch is CancellationError {
                await self?.respond(
                    with: ResponseError(id: body.id, error: WKWeb3Error(.userRejectedRequest))
                )
            } catch let error as WKWeb3Error {
                #if DEBUG
                switch error.code {
                case .unsupportedMethod:
                    let value = (try? JSONSerialization.jsonObject(with: body.request)) ?? [:]
                    print("[WKWeb3Configuration]: Did handle unsupported method: \(body.method) - \(value)")
                default:
                    break
                }
                #endif
                
                await self?.respond(
                    with: ResponseError(id: body.id, error: error)
                )
            } catch {
                await self?.respond(
                    with: ResponseError(id: body.id, error: WKWeb3Error(.internal))
                )
            }
        }
    }
}
