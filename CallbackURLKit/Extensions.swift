//
//  Extensions.swift
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

extension String {
    var parseURLParams: [String : String] {
        var result: [String : String] = [String : String]()
        let pairs: [String] = self.componentsSeparatedByString("&")
        for pair in pairs {
            var comps: [String] = pair.componentsSeparatedByString("=")
            if comps.count >= 2 {
                let key = comps[0]
                let value = comps.dropFirst().joinWithSeparator("=")
                result[key] = value.stringByRemovingPercentEncoding
            }
        }
        return result
    }

    var ampersandEncoded: String? {
        let nonAmpersandCharacters = NSCharacterSet(charactersInString: "&").invertedSet
        return self.stringByAddingPercentEncodingWithAllowedCharacters(nonAmpersandCharacters)
    }
}

extension Dictionary {

    var query: String {
        var parts = [String]()
        for (key, value) in self {
            let keyString = "\(key)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let valueString = "\(value)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let query = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        return parts.joinWithSeparator("&") as String
    }
    
    func join(other: Dictionary) -> Dictionary {
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


extension NSURLComponents {
    func addToQuery(add: String) {
        if let query = self.query {
            self.query = query + "&" + add
        } else {
            self.query = add
        }
    }
    
}

func &= (left: NSURLComponents, right: String) {  left.addToQuery(right) }

