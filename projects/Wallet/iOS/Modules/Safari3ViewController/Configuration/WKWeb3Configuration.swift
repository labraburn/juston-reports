//
//  WKWeb3Configuration.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation
import WebKit

final class WKWeb3Configuration: WKWebViewConfiguration {
    
    private var events: [String : WKWeb3EventBox] = [
        WKWeb3EventBox(WKWeb3AuthenticateEvent.self),
        WKWeb3EventBox(WKWeb3SignEvent.self),
    ].reduce(into: [:], { $0[$1.name] = $1 })
    
    weak var dispatcher: WKWeb3EventDispatcher?
    
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
    }
}

extension WKWeb3Configuration: WKScriptMessageHandler {
    
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    
    private struct BodyRequest: Decodable {
        
        let id: String
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
                    id: body.id,
                    with: ResponseError(id: body.id, error: WKWeb3Error(.unsupportedMethod))
                )
                return
            }
            
            do {
                let response = ResponseResult(
                    id: body.id,
                    result: try await type.process(
                        body.request,
                        WKWeb3Configuration.decoder,
                        WKWeb3Configuration.encoder
                    )
                )
                
                let data = try WKWeb3Configuration.encoder.encode(response)
                guard let string = String(data: data, encoding: .utf8)
                else {
                    throw WKError(.unknown)
                }
                
                try await self?.dispatcher?.dispatch(
                    string
                )
            } catch let error as WKWeb3Error {
                await self?.respond(
                    id: body.id,
                    with: ResponseError(id: body.id, error: error)
                )
            } catch {
                await self?.respond(
                    id: body.id,
                    with: ResponseError(id: body.id, error: WKWeb3Error(.internal))
                )
            }
        }
    }
    
    private func respond(
        id: String,
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
        
        try? await dispatcher?.dispatch(
            message
        )
    }
}
