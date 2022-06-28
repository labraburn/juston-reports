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
        WKWeb3EventBox(WKWeb3SignEvent.self),
        WKWeb3EventBox(WKWeb3UndefinedEvent.self),
    ].reduce(into: [:], { events, box in
        box.names.forEach({ events[$0] = box })
    })
    
    weak var dispatcher: WKWeb3EventDispatcher?
    var account: PersistenceAccount?
    
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
            
            guard let context = self?.dispatcher?.context
            else {
                await self?.respond(
                    id: body.id,
                    with: ResponseError(id: body.id, error: WKWeb3Error(.disconnected))
                )
                return
            }
            
            do {
                let response = ResponseResult(
                    id: body.id,
                    result: try await type.process(
                        self?.account,
                        context,
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
                
            } catch is CancellationError {
                await self?.respond(
                    id: body.id,
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

// async onDappMessage(method, params) {
//     // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1193.md
//     // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1102.md
//     await this.whenReady;

//     const needQueue = !popupPort;

//     switch (method) {
//         case 'ton_requestAccounts':
//             return (this.myAddress ? [this.myAddress] : []);
//         case 'ton_requestWallets':
//             if (!this.myAddress) {
//                 return [];
//             }
//             if (!this.publicKeyHex) {
//                 await this.requestPublicKey(needQueue);
//             }
//             const walletVersion = await storage.getItem('walletVersion');
//             return [{
//                 address: this.myAddress,
//                 publicKey: this.publicKeyHex,
//                 walletVersion: walletVersion
//             }];
//         case 'ton_getBalance':
//             await this.update(true);
//             return (this.balance ? this.balance.toString() : '');
//         case 'ton_sendTransaction':
//             const param = params[0];
//             await showExtensionWindow();

//             if (param.data) {
//                 if (param.dataType === 'hex') {
//                     param.data = TonWeb.utils.hexToBytes(param.data);
//                 } else if (param.dataType === 'base64') {
//                     param.data = TonWeb.utils.base64ToBytes(param.data);
//                 } else if (param.dataType === 'boc') {
//                     param.data = TonWeb.boc.Cell.oneFromBoc(TonWeb.utils.base64ToBytes(param.data));
//                 }
//             }
//             if (param.stateInit) {
//                 param.stateInit = TonWeb.boc.Cell.oneFromBoc(TonWeb.utils.base64ToBytes(param.stateInit));
//             }

//             this.sendToView('showPopup', {
//                 name: 'loader',
//             });

//             const result = await this.showSendConfirm(new BN(param.value), param.to, param.data, needQueue, param.stateInit);
//             if (!result) {
//                 this.sendToView('closePopup');
//             }
//             return result;
//         case 'ton_rawSign':
//             const signParam = params[0];
//             await showExtensionWindow();

//             return this.showSignConfirm(signParam.data, needQueue);
//         case 'flushMemoryCache':
//             await chrome.webRequest.handlerBehaviorChanged();
//             return true;
//     }
// }
