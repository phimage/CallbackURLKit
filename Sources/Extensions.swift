//
//  Extensions.swift
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

// MARK: String
extension String {

    var toQueryDictionary: [String : String] {
        var result: [String : String] = [String : String]()
        let pairs: [String] = self.components(separatedBy: "&")
        for pair in pairs {
            var comps: [String] = pair.components(separatedBy: "=")
            if comps.count >= 2 {
                let key = comps[0]
                let value = comps.dropFirst().joined(separator: "=")
                result[key.queryDecode] = value.queryDecode
            }
        }
        return result
    }

    var queryEncodeRFC3986: String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn : generalDelimitersToEncode + subDelimitersToEncode)
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
    }
    
    var queryEncode: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    var queryDecode: String {
        return self.removingPercentEncoding ?? self
    }

}

// MARK: Dictionary
extension Dictionary {

    var queryString: String {
        var parts = [String]()
        for (key, value) in self {
            let keyString = "\(key)".queryEncodeRFC3986
            let valueString = "\(value)".queryEncodeRFC3986
            let query = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        return parts.joined(separator: "&") as String
    }
    
    fileprivate func join(_ other: Dictionary) -> Dictionary {
        var joinedDictionary = Dictionary()
        
        for (key, value) in self {
            joinedDictionary.updateValue(value, forKey: key)
        }
        
        for (key, value) in other {
            joinedDictionary.updateValue(value, forKey: key)
        }
        
        return joinedDictionary
    }
    
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
}
func +<K, V> (left: [K : V], right: [K : V]) -> [K : V] { return left.join(right) }


// MARK: NSURLComponents
extension URLComponents {

    var queryDictionary: [String: String] {
        get {
            guard let query = self.query else {
                return [:]
            }
            return query.toQueryDictionary
        }
        set {
            if newValue.isEmpty {
                self.query = nil
            } else {
                self.percentEncodedQuery = newValue.queryString
            }
        }
    }

    fileprivate mutating func addToQuery(_ add: String) {
        if let query = self.percentEncodedQuery {
            self.percentEncodedQuery = query + "&" + add
        } else {
            self.percentEncodedQuery = add
        }
    }
    
}

func &= (left: inout URLComponents, right: String) { left.addToQuery(right) }

