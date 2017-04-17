//
//  Manager.swift
//  CallbackURLKit
/*
The MIT License (MIT)
Copyright (c) 2016 Eric Marchand (phimage)
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

open class Manager {

    // singletong shared instance
    open static let shared = Manager()

    // List of action/action closure
    var actions: [Action: ActionHandler] = [:]
    // keep request for callback
    var requests: [RequestID: Request] = [:]
    
    // Specify an URL scheme for callback
    open var callbackURLScheme: String?
    
    // no Action Match 
    open var noMatchActionCallback: NoActionMatchCallback?
    
    init() {
    }
    
    // Add an action handler ie. url path and block
    open subscript(action: Action) -> ActionHandler? {
        get {
            return actions[action]
        }
        set {
            if newValue == nil {
                actions.removeValue(forKey: action)
            } else {
                actions[action] = newValue
            }
        }
    }

    // Handle url from app delegate
    open func handleOpen(url: URL) -> Bool {
        if url.scheme != self.callbackURLScheme || url.host != kXCUHost {
            return false
        }
        let path = url.path

        let action = String(path.characters.dropFirst()) // remove /

        let parameters = url.query?.toQueryDictionary ?? [:]
        let actionParameters = Manager.action(parameters: parameters)
        
        // is a reponse?
        if action == kResponse {
            if let requestID = parameters[kRequestID] /*as? RequestID*/, let request = requests[requestID] {
                
                if let rawType = parameters[kResponseType], let responseType = ResponseType(rawValue: rawType) {
                    switch responseType {
                    case .success:
                        request.successCallback?(actionParameters)
                    case .error:
                        request.failureCallback?(request.client.error(code: parameters[kXCUErrorCode], message: parameters[kXCUErrorMessage]))
                    case .cancel:
                        request.cancelCallback?()
                    }
                    
                    requests.removeValue(forKey: requestID)
                }
                return true
            }
            return false
        }
        else if let actionHandler = actions[action] { // handle the action
            let successCallback: SuccessCallback =  { [weak self] returnParams in
                self?.openCallback(parameters, type: .success) { comp in
                    if let query = returnParams?.queryString {
                        comp &= query
                    }
                }
            }
            let failureCallback: FailureCallback = { [weak self] error in
                self?.openCallback(parameters, type: .error) { comp in
                    comp &= error.XCUErrorQuery
                }
            }
            let cancelCallback: CancelCallback = { [weak self] in
                self?.openCallback(parameters, type: .cancel)
            }
            
            actionHandler(actionParameters, successCallback, failureCallback, cancelCallback)
            return true
        }
        else {
            // unknown action, notifiy it
            if let errorURLString = parameters[kXCUError], let url = URL(string: errorURLString) {
                let error = NSError.error(code: .notSupportedAction, failureReason: "\(action) not supported by \(Manager.appName)")
   
                var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                comp &= error.XCUErrorQuery
                if let newURL = comp.url {
                    Manager.open(url: newURL)
                }
                return true
            } else {
                if let noMatchActionCallback = noMatchActionCallback {
                    noMatchActionCallback(parameters)
                }
            }
        }
        return false
    }
    
    fileprivate func openCallback(_ parameters: [String : String], type: ResponseType, handler: ((inout URLComponents) -> Void)? = nil ) {
        if let urlString = parameters[type.key], let url = URL(string: urlString),
            var comp = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            handler?(&comp)
            if let newURL = comp.url {
                Manager.open(url: newURL)
            }
        }
    }

    // Handle url with manager shared instance
    open static func handleOpen(url: URL) -> Bool {
        return self.shared.handleOpen(url: url)
    }
    
    // MARK: - perform action with temporary client

    // Perform an action on client application
    // - Parameter action: The action to perform.
    // - Parameter urlScheme: The application scheme to apply action.
    // - Parameter parameters: Optional parameters for the action.
    // - Parameter onSuccess: callback for success.
    // - Parameter onFailure: callback for failure.
    // - Parameter onCancel: callback for cancel.
    //
    // Throws: CallbackURLKitError
    open func perform(action: Action, urlScheme: String, parameters: Parameters = [:],
        onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {
            let client = Client(urlScheme: urlScheme)
            client.manager = self
        try client.perform(action: action, parameters: parameters, onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }

    open static func perform(action: Action, urlScheme: String, parameters: Parameters = [:],
        onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {
        try Manager.shared.perform(action: action, urlScheme: urlScheme, parameters: parameters, onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }
    
    // Utility function to get URL schemes from Info.plist
    open static var urlSchemes: [String]? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]] else {
            return nil
        }
        var result = [String]()
        for urlType in urlTypes {
            if let schemes = urlType["CFBundleURLSchemes"] as? [String] {
                result += schemes
            }
        }
        return result.isEmpty ? nil : result
    }

    // MARK: internal


    func send(request: Request) throws {
        if !request.client.appInstalled {
            throw CallbackURLKitError.appWithSchemeNotInstalled(scheme: request.client.urlScheme)
        }
        
        var query: Parameters = [:]
        query[kXCUSource] = Manager.appName
        
        if let scheme = self.callbackURLScheme {
            
            var xcuComponents = URLComponents()
            xcuComponents.scheme = scheme
            xcuComponents.host = kXCUHost
            xcuComponents.path = "/" + kResponse
 
            let xcuParams: Parameters = [kRequestID: request.ID]

            for reponseType in request.responseTypes {
                xcuComponents.queryDictionary = xcuParams + [kResponseType: reponseType.rawValue]
                if let urlString = xcuComponents.url?.absoluteString {
                    query[reponseType.key] = urlString
                }
            }
            
            if request.hasCallback {
                requests[request.ID] = request
            }

        }
        else if request.hasCallback {
            throw CallbackURLKitError.callbackURLSchemeNotDefined
        }
        let components = request.URLComponents(query)
        guard let URL = components.url else {
            throw CallbackURLKitError.failedToCreateRequestURL(components: components)
        }

        Manager.open(url: URL)
    }

    static func action(parameters: [String : String]) -> [String : String] {
        let resultArray: [(String, String)] = parameters.filter { tuple in
            return !(tuple.0.hasPrefix(kXCUPrefix) || protocolKeys.contains(tuple.0))
        }
        var result = [String: String](resultArray)
        if let source = parameters[kXCUSource] {
            result[kXCUSource] = source
        }
        return result
    }

    static func open(url: Foundation.URL) {
        #if os(iOS) || os(tvOS)
            UIApplication.shared.openURL(url)
        #elseif os(OSX)
            NSWorkspace.shared().open(url)
        #endif
    }

    static var appName: String {
        if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        }
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "CallbackURLKit"
    }

}


#if os(OSX)
extension Manager {

    public func registerToURLEvent() {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(Manager.handleURLEvent(_:withReply:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    @objc public func handleURLEvent(_ event: NSAppleEventDescriptor, withReply replyEvent: NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = URL(string: urlString) {
            let _ = handleOpen(url: url)
        }
    }

}
#endif
