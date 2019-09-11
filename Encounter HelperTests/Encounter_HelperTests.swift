//
//  Encounter_HelperTests.swift
//  Encounter HelperTests
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import XCTest
@testable import Encounter_Helper

class Encounter_HelperTests: XCTestCase {

    var fileURL:URL?
    var monsterArray:[MonsterModel]?
    var monsterMetaArray:[MonsterMetaModel]?

    override func setUp() {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        if let path = Bundle.main.path(forResource: "5e-SRD-Monsters", ofType: "json") {
            fileURL = URL(fileURLWithPath:path)
        } else {
            XCTAssert(false)
        }
        
        do {
            let data = try Data(contentsOf: fileURL!, options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                monsterArray = try decoder.decode([MonsterModel].self, from: data)
            } catch {
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testExample2() {
        if let path = Bundle.main.path(forResource: "conditions", ofType: "json") {
            fileURL = URL(fileURLWithPath:path)
        } else {
            XCTAssert(false)
        }
        
        do {
            let data = try Data(contentsOf: fileURL!, options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                let _ = try decoder.decode(Conditions.self, from: data)
            } catch {
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
