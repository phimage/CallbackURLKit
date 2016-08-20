//
//  Manager.swift
//  CallbackURLKit
/*
The MIT License (MIT)
Copyright (c) 2015 Eric Marchand (phimage)
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

public class Manager {

    // singletong shared instance
    public static let sharedInstance = Manager()

    // List of action/action closure
    var actions: [Action: ActionHandler] = [:]
    // keep request for callback
    var requests: [RequestID: Request] = [:]
    
    // Specify an URL scheme for callback
    public var callbackURLScheme: String?
    
    init() {
    }
    
    // Add an action handler ie. url path and block
    public subscript(action: Action) -> ActionHandler? {
        get {
            return actions[action]
        }
        set {
            if newValue == nil {
                actions.removeValueForKey(action)
            } else {
                actions[action] = newValue
            }
        }
    }

    // Handle url from app delegate
    public func handleOpenURL(url: NSURL) -> Bool {
        if url.scheme != self.callbackURLScheme || url.host != kXCUHost {
            return false
        }
        guard let path = url.path else {
            return false
        }

        let action = String(path.characters.dropFirst()) // remove /

        let parameters = url.query?.parseURLParams ?? [:]
        let actionParameters = Manager.actionParameters(parameters)
        
        // is a reponse?
        if action == kResponse {
            if let requestID = parameters[kRequestID] /*as? RequestID*/, request = requests[requestID] {
                
                if let rawType = parameters[kResponseType], responseType = ResponseType(rawValue: rawType) {
                    switch responseType {
                    case .success:
                        request.successCallback?(actionParameters)
                    case .error:
                        request.failureCallback?(request.client.errorForCode(parameters[kXCUErrorCode], message: parameters[kXCUErrorMessage]))
                    case .cancel:
                        request.cancelCallback?()
                    }
                    
                    requests.removeValueForKey(requestID)
                }
                return true
            }
            return false
        }
        else if let actionHandler = actions[action] { // handle the action
            let successCallback =  { (returnParams: Parameters?) in
                if let urlString = parameters[kXCUSuccess], url = NSURL(string: urlString) {
                    // returnParams
                    let comp = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
		    if let requestID = parameters[kRequestID] {
                        comp &= "\(kRequestID)=\(requestID)"
                    }
                    if let query = returnParams?.query {
                        comp &= query
                    }
                    if let newURL = comp.URL {
                        Manager.openURL(newURL)
                    }
                }
            }
            let failureCallback = { (error: FailureCallbackErrorType) in
                if let urlString = parameters[kXCUError], url = NSURL(string: urlString) {
                    let comp = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
		    if let requestID = parameters[kRequestID] {
                        comp &= "\(kRequestID)=\(requestID)"
                    }
                    comp &= error.XCUErrorQuery
                    if let newURL = comp.URL {
                        Manager.openURL(newURL)
                    }
                }
            }
            let cancelCallback = {
                if let urlString = parameters[kXCUCancel], url = NSURL(string: urlString) {
		    let comp = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
                    if let requestID = parameters[kRequestID] {
                        comp &= "\(kRequestID)=\(requestID)"
                    }
                    if let newURL = comp.URL {
                        Manager.openURL(newURL)
                    }
                }
            }
            
            actionHandler(actionParameters, successCallback, failureCallback, cancelCallback)
            return true
        }
        else {
            // unknown action, notifiy it
            if let errorURLString = parameters[kXCUError], url = NSURL(string: errorURLString) {
                let error = Error.errorWithCode(.NotSupportedAction, failureReason: "\(action) not supported by \(Manager.appName)")
   
                let comp = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
                comp &= error.XCUErrorQuery
                if let newURL = comp.URL {
                    Manager.openURL(newURL)
                }
                return true
            }
        }
        return false
    }

    // Handle url with manager shared instance
    public static func handleOpenURL(url: NSURL) -> Bool {
        return self.sharedInstance.handleOpenURL(url)
    }
    
    // MARK: - perform action with temporary client

    // Perform an action on client application
    // - Parameter action: The action to perform.
    // - Parameter URLScheme: The application scheme to apply action.
    // - Parameter parameters: Optional parameters for the action.
    // - Parameter onSuccess: callback for success.
    // - Parameter onFailure: callback for failure.
    // - Parameter onCancel: callback for cancel.
    //
    // Throws: CallbackURLKitError
    public func performAction(action: Action, URLScheme: String, parameters: Parameters = [:],
        onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {
            let client = Client(URLScheme: URLScheme)
            client.manager = self
            try client.performAction(action, parameters: parameters, onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }

    public static func performAction(action: Action, URLScheme: String, parameters: Parameters = [:],
        onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {
            try Manager.sharedInstance.performAction(action, URLScheme: URLScheme, parameters: parameters, onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }
    
    // Utility function to get URL schemes from Info.plist
    public static var URLSchemes: [String]? {
        guard let urlTypes = NSBundle.mainBundle().infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]] else {
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

    func sendRequest(request: Request) throws {
        if !request.client.appInstalled {
            throw CallbackURLKitError.AppWithSchemeNotInstalled(scheme: request.client.URLScheme)
        }
        
        var query: Parameters = [:]
        query[kXCUSource] = Manager.appName
        
        if let scheme = self.callbackURLScheme {
            
            let xcuComponents = NSURLComponents()
            xcuComponents.scheme = scheme
            xcuComponents.host = kXCUHost
            xcuComponents.path = kResponse
 
            let xcuParams: Parameters = [kRequestID: request.ID]
            
            if request.successCallback != nil {
                xcuComponents.query = (xcuParams + [kResponseType: ResponseType.success.rawValue]).query
                query[kXCUSuccess] = xcuComponents.URL?.absoluteString ?? ""
                
                xcuComponents.query = (xcuParams + [kResponseType: ResponseType.cancel.rawValue]).query
                query[kXCUCancel] = xcuComponents.URL?.absoluteString ?? ""
            }
            if request.failureCallback != nil {
                xcuComponents.query = (xcuParams + [kResponseType: ResponseType.error.rawValue]).query
                query[kXCUError] = xcuComponents.URL?.absoluteString ?? ""
            }
            
            if request.hasCallback {
                requests[request.ID] = request
            }

        }
        else if request.hasCallback {
            throw CallbackURLKitError.CallbackURLSchemeNotDefined
        }
        let components = request.URLComponents(query)
        guard let URL = components.URL else {
            throw CallbackURLKitError.FailedToCreateRequestURL(components: components)
        }

        Manager.openURL(URL)
    }

    static func actionParameters(parameters: [String : String]) -> [String : String] {
        let resultArray: [(String, String)] = parameters.filter { tuple in
            return !(tuple.0.hasPrefix(kXCUPrefix) || protocolKeys.contains(tuple.0))
        }
        var result = [String: String](resultArray)
        if let source = parameters[kXCUSource] {
            result[kXCUSource] = source
        }
        return result
    }

    static func openURL(URL: NSURL) {
        #if os(iOS) || os(tvOS)
            UIApplication.sharedApplication().openURL(URL)
        #elseif os(OSX)
            NSWorkspace.sharedWorkspace().openURL(URL)
        #endif
    }

    static var appName: String {
        if let appName = NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String{
            return appName
        }
        return NSBundle.mainBundle().infoDictionary?["CFBundleDisplayName"] as? String ?? "CallbackURLKit"
    }

}


#if os(OSX)
extension Manager {

    public func registerToURLEvent() {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector:"handleGetURLEvent:withReplyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    public func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent replyEvent: NSAppleEventDescriptor!)
    {
        if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue, url = NSURL(string: urlString) {
            handleOpenURL(url)
        }
    }

}
#endif