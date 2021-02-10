//
//  Ulysses
//  CallbackURLKit
/*
 The MIT License (MIT)
 Copyright (c) 2017 Eric Marchand (phimage)
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
#if IMPORT
    import CallbackURLKit
#endif
import Foundation

/*
 Client for ulysses app https://ulyssesapp.com
 https://ulyssesapp.com/kb/x-callback-url/
 */
public class Ulysses: Client {

    public enum UlyssesError: Int, FailureCallbackError {

        case noAccessToken = 31

        public var message: String {
            switch self {
            case .noAccessToken:
                return "No access token provided"
            }
        }

        public var code: Int {
            return self.rawValue
        }

    }

    public init() {
        super.init(urlScheme: "ulysses")
    }

    /*
     To protect the Ulysses library against access from malicious apps, actions that expose content or destructively change require the calling app to be authorized.
     
     @param appName   your app name
     @param onSuccess  the success callback where you will receive the access-token as String.
     
     Available since Ulysses 2.8 (API version 2).
     */
    public func authorize(appName: String, onSuccess: @escaping (_ token: String) -> Void, onFailure: FailureCallback? = nil) throws {
        try self.perform(action: "authorize", parameters: ["appname": appName], onSuccess: { parameters in
            if let token = parameters?["access-token"] {
                onSuccess(token)
            } else {
                onFailure?(UlyssesError.noAccessToken)
            }
        }, onFailure: onFailure)
    }

    /*
     Creates a new sheet.
     Available on iOS since Ulysses 2.6 (API version 1), on Mac since Ulysses 2.8 (API version 2).
     
     @param text The contents that should be inserted to the new sheet. Must be URL-encoded. Contents are imported as Markdown by default.
     
     @param group Optional. Specifies the group the new sheet should be inserted to. This argument can be set to one of the following values:
     - A group name (e.g. My Group) that will match the first group having the same name, regardless of its position in the group hierarchy.
     - A path to a particular target group (e.g. /My Group/My Subgroup). Any path must begin with a slash. (More…)
     - A unique identifier of the target group. (More…)
     If no value is given, the sheet is created inside the Inbox.
     @param format Optional. Specifies the format of the imported text: markdown, text, html. Defaults to Markdown.
     @param index  Optional. The position of the new sheet in its parent group. Use 0 to make it the first sheet. Available since Ulysses 2.8 (API version 2).
     */
    public func newSheet(text: String, group: String? = nil, format: String? = nil, index: String? = nil, onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {

        var parameters = ["text": text]
        if let group = group {
            parameters["group"] = group
        }
        if let format = format {
            parameters["format"] = format
        }
        if let index = index {
            parameters["index"] = index
        }

        try self.perform(action: "new-sheet", parameters: parameters, onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }

}
