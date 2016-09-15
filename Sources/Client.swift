//
//  Client.swift
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

// Client application
open class Client {

    open var urlScheme: String
    open var manager: Manager?
    
    public init(urlScheme: String) {
        self.urlScheme = urlScheme
    }
 
    open var appInstalled: Bool {
        guard let url = URL(string:"\(self.urlScheme)://dummy") else {
            return false
        }
        #if os(iOS) || os(tvOS)
            return UIApplication.shared.canOpenURL(url)
        #elseif os(OSX)
            return NSWorkspace.shared().urlForApplication(toOpen: url) != nil
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

    open func perform(action: Action, parameters: Parameters = [:],
                      onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {
        
        let request = Request(
            ID: UUID().uuidString, client: self,
            action: action, parameters: parameters,
            successCallback: onSuccess, failureCallback: onFailure, cancelCallback:  onCancel
        )

        let manager = self.manager ?? Manager.shared
        try manager.send(request: request)
    }

    // Return an error according to url, could be changed to fulfiled your need
    open func error(code: String?, message: String?) -> FailureCallbackError {
        let codeInt: Int
        if let c = code, let ci = Int(c)  {
            codeInt = ci
        } else {
            codeInt = ErrorCode.missingErrorCode.rawValue
        }
        return NSError.error(code: codeInt, failureReason: message ?? "")
    }

}
