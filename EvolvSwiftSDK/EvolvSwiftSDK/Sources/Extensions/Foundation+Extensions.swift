//
//  Swift+Extensions.swift
//  EvolvSwiftSDK
//
//  Created by Alim Yuzbashev on 20.08.2021.
//

import Foundation

extension String {
    func regexMatch(regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let firstMatch = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self))
            
            return firstMatch?.range.length != 0
        } catch {
            print("Evolv: invalid regex. Regex: \(regex), text: \(self). Error: \(error)")
            return false
        }
    }
    
    func regexMatches(regex: String, options: NSRegularExpression.MatchingOptions = []) throws -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            
            let range = NSRange(location: 0, length: self.count)
            
            return regex.matches(in: self, options: options, range: range)
        } catch {
            print("Evolv: invalid regex. Regex: \(regex), text: \(self). Error: \(error)")
            
            throw error
        }
    }
    
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
    
    func evolvHashCode() -> Int {
        var ret = 0
        var i = 0
        
        while i < self.count {
            let scalarCharacterCode = Int(self[i].unicodeScalars.first?.value ?? 0)
            
            ret = ((31 * ret + scalarCharacterCode))
            
            i += 1
        }
        
        return ret
        
    }
}

extension Dictionary {
    mutating func removeValues(forKeys keys: [Key]) {
        keys.forEach {
            self.removeValue(forKey: $0)
        }
    }
    
    func withoutValues(withKeys keys: [Key]) -> Self {
        var dict = self
        dict.removeValues(forKeys: keys)
        return dict
    }
}

extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, fromJSONObject obj: Any, options: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: obj, options: options)
        
        return try self.decode(type, from: data)
    }
}

extension Sequence where Element: Hashable {
    func set() -> Set<Element> {
        return Set(self)
    }
}
