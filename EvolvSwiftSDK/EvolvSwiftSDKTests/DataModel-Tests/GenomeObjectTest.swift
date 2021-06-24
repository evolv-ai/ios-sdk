//
//  TestGenomeObject.swift
//
//  Copyright (c) 2021 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import XCTest
@testable import EvolvSwiftSDK

class GenomeObjectTest: XCTestCase {
    
    static var sampleData = """
        {
            "home": {
                "cta_text": "Click Here"
            },
            "next": {
                "layout": "Default Layout"
            }
        }
        """
    
    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        jsonDecoder = JSONDecoder()
    }

    override func tearDown() {
        super.tearDown()
        
        jsonDecoder = nil
    }
    
    func testValueTypesSuccess() {
        
        // MARK: - Given
        
        let integer1 = GenomeObject(5)
        let double1 = GenomeObject(10.2)
        let integer2 = GenomeObject(0)
        let integer3 = GenomeObject(Int8(12))
        let integer4 = GenomeObject(-1_234_567)
        let integer5 = GenomeObject(1)
        let string1 = GenomeObject("")
        let string2 = GenomeObject("foo")
        let bool1 = GenomeObject(false)
        let bool2 = GenomeObject(true)
        let bool3 = GenomeObject(0)
        let bool4 = GenomeObject(1)
        let array1 = GenomeObject([])
        let array2 = GenomeObject([1, 2, 3])
        let array3 = GenomeObject(["1", "2", "3"])
        let array4 = GenomeObject(["1", 2, true])
        let dict1 = GenomeObject([:])
        let dict2 = GenomeObject(["1": 2, "3": 4])
        let null1 = GenomeObject(NSNull())
        let null2 = GenomeObject.null
//        let unknown = GenomeObject(Data())
        
        
        // MARK: - Integer and Double

        XCTAssertEqual(integer1.type, GenomeObject.ValueType.number)
        XCTAssertEqual(integer1, 5)
        XCTAssertEqual(double1.type, GenomeObject.ValueType.number)
        XCTAssertEqual(double1, 10.2)
        XCTAssertEqual(integer2.type, GenomeObject.ValueType.number)
        XCTAssertEqual(integer2, 0)
        XCTAssertEqual(integer3.type, GenomeObject.ValueType.number)
        XCTAssertEqual(integer3, 12)
        XCTAssertEqual(integer4.type, GenomeObject.ValueType.number)
        XCTAssertEqual(integer4, -1234567)
        XCTAssertEqual(integer5.type, GenomeObject.ValueType.number)
        XCTAssertEqual(integer5, 1)
        
        // MARK: - String
        
        XCTAssertEqual(string1.type, GenomeObject.ValueType.string)
        XCTAssertEqual(string1, "")
        XCTAssertEqual(string2.type, GenomeObject.ValueType.string)
        XCTAssertEqual(string2, "foo")
        
        // MARK: - Bool
        
        XCTAssertEqual(bool1.type, GenomeObject.ValueType.bool)
        XCTAssertEqual(bool1, false)
        XCTAssertEqual(bool2.type, GenomeObject.ValueType.bool)
        XCTAssertEqual(bool2, true)
        XCTAssertNotEqual(bool3.type, GenomeObject.ValueType.bool)
        XCTAssertNotEqual(bool4.type, GenomeObject.ValueType.bool)
        
        // MARK: - Array
        
        XCTAssertEqual(array1.type, GenomeObject.ValueType.array)
        XCTAssertEqual(array1, [])
        XCTAssertEqual(array2.type, GenomeObject.ValueType.array)
        XCTAssertEqual(array2, [1, 2, 3])
        XCTAssertEqual(array3.type, GenomeObject.ValueType.array)
        XCTAssertEqual(array3, ["1", "2", "3"])
        XCTAssertEqual(array4.type, GenomeObject.ValueType.array)
        XCTAssertEqual(array4, ["1", 2, true])
        
        // MARK: - Dictionary
        
        XCTAssertEqual(dict1.type, GenomeObject.ValueType.dictionary)
        XCTAssertEqual(dict1, [:])
        XCTAssertEqual(dict2.type, GenomeObject.ValueType.dictionary)
        XCTAssertEqual(dict2, ["1": 2, "3": 4])
        
        // MARK: - Null
        
        XCTAssertEqual(null1.type, .null)
        XCTAssertEqual(null1, GenomeObject(NSNull()))
        XCTAssertEqual(null2.type, .null)
        XCTAssertEqual(null2, GenomeObject(NSNull()))
        
        // MARK: - Unknown
//        XCTAssertEqual(unknown.type, .unknown)
    }
}

// MARK: - Decode

extension GenomeObjectTest {
    
    func testDecodeSuccessWithJSONValid() {
        let jsonData = GenomeObjectTest.sampleData
        var genome: GenomeObject?
        
        do {
            let data = jsonData.data(using: .utf8)!
            genome = try jsonDecoder.decode(GenomeObject.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(genome)
        XCTAssertEqual(genome?.type, .dictionary)
    }
    
    func testDecodeKeysSuccessWithJSON() {
        let jsonData = GenomeObjectTest.sampleData
        var genome: GenomeObject?
        
        do {
            let data = jsonData.data(using: .utf8)!
            genome = try jsonDecoder.decode(GenomeObject.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(genome)
        XCTAssertEqual(genome?.type, .dictionary)
        XCTAssertEqual(try? genome?.parse(forKey: "home")?.type, .dictionary)
        XCTAssertEqual(try? genome?.parse(forKey: "home.cta_text"), "Click Here")
        XCTAssertEqual(try? genome?.parse(forKey: "next")?.type, .dictionary)
        XCTAssertEqual(try? genome?.parse(forKey: "next.layout"), "Default Layout")
    }
    
    func testDecodeFailWithMissingKey() {
        
    }
    
    func testDecodeFailWithSimilarKeys() {
        
    }
    
    
    
}

