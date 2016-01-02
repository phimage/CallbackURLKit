//
//  Client.swift
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

// Client application
public class Client {

    public var URLScheme: String
    public var manager: Manager?
    
    public init(URLScheme: String) {
        self.URLScheme = URLScheme
    }
 
    public var appInstalled: Bool {
        guard let url = NSURL(string:"\(self.URLScheme)://dummy") else {
            return false
        }
        #if os(iOS) || os(tvOS)
            return UIApplication.sharedApplication().canOpenURL(url)
        #elseif os(OSX)
            return NSWorkspace.sharedWorkspace().URLForApplicationToOpenURL(url) != nil
        #endif
    }

    // Perform an action on client application
    // - Parameter action: The action to perform.
    // - Parameter parameters: Optional parameters for the action.
    // - Parameter onSuccess: callback for success.
    // - Parameter onFailure: callback for failure.
    // - Parameter onCancel: callback for cancel.
    //
    // Throws: CallbackURLKitError
    
    public func performAction(action: Action, parameters: Parameters = [:],
        onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {

            let request = Request(
                ID: NSUUID().UUIDString, client: self,
                action: action, parameters: parameters,
                successCallback: onSuccess, failureCallback: onFailure, cancelCallback:  onCancel
            )
            
            let manager = self.manager ?? Manager.sharedInstance
            try manager.sendRequest(request)
    }
    
    // Return an error according to url, could be changed to fulfiled your need
    public func errorForCode(code: String?, message: String?) -> FailureCallbackErrorType {
        let codeInt = 30 //TODO convert string to int
        
        var userInfo = [String: String]()
        if let msg = message {
            userInfo[NSLocalizedDescriptionKey] = msg
        }
        
        return NSError(domain: CallbackURLKitErrorDomain, code: codeInt, userInfo: userInfo)
    }

}
