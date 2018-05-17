#!/usr/bin/swift -F ./

import Foundation
import RandomKit
import Rainbow

let dataFilePath = "./lotto1-806.json"

struct LottoCollection: Codable {
    var lottos: [Lotto]
}

struct Lotto: Codable {
    var order: Int
    var number: [Int]
    var bonus: Int
}

typealias LuckyNumber = [Int]

var randomGenerator = Xoroshiro.default
let range = 1...45
let count = 1...6

func printFatal(_ string: String) {
    print("[Failed]".red.blink + " \(string)")
}

func printError(_ string: String) {
    print("[Error]".magenta + " \(string)")
}

func printInfo(_ string: String) {
    print("[Info]".green + " \(string)")
}

func printLuckyBlink(_ string: String) {
    print("[Lucky]".green.blink.bold + " \(string)")
}


var luckyNumber: LuckyNumber? {
    var random = LuckyNumber()

    for _ in count {
        let number = Int.random(in: range, using: &randomGenerator)
        if random.contains(number) {
            //printError("\(random) contains \(number)")
            return nil
        }
        random.append(number)
    }
    random.sort()
    
    return random
}

func loadData() -> LottoCollection? {
    let fileManager = FileManager.default
    guard let jsonData = fileManager.contents(atPath: dataFilePath) else {
        printError("Can not load file.")
        return nil
    }
    
    let decoder = JSONDecoder()
    
    let lottoCollection = try? decoder.decode(LottoCollection.self, from: jsonData)

    printInfo(">> loaded lotto count: \(lottoCollection?.lottos.count ?? 0)")
    return lottoCollection
}



func maekLuckyNumber(luckyCount: [Int])  {
    func luckyNumberAt(at: Int) -> LuckyNumber {
        var retryCount = 0
        while true {
            
            guard let luckyNumber = luckyNumber else {
                continue
            }
            retryCount += 1
            
            if retryCount == at {
                return luckyNumber
                //break
            }
        }
    }
    
    
    for at in luckyCount {
        let number = luckyNumberAt(at: at)
        printLuckyBlink("\(at), Lucky Number: \(number)")
    }
    
}



func testLuckyMain(targetIndex: Int = -1, count: Int = 100) throws {
    
    func matchedLucky(index: Int, lotto: Lotto) -> Int {
        var retryCount = 0
        while true {
            retryCount += 1
            
            guard let luckyNumber = luckyNumber else {
                continue
            }
            
            if lotto.number == luckyNumber {
                printLuckyBlink("\(index), \(retryCount), Matched Item: \(lotto)")
                break
            }
        }
        return retryCount
    }
    
    guard let lottoCollection = loadData() else {
        return
    }
    
    var selectedLotto: Lotto
    if  lottoCollection.lottos.startIndex <= targetIndex &&
        targetIndex < lottoCollection.lottos.endIndex  {
        selectedLotto = lottoCollection.lottos[targetIndex]
    } else {
        selectedLotto = lottoCollection.lottos.first!
    }

    var total = 0
    for index in 1...count {
        total += matchedLucky(index: index, lotto: selectedLotto)
    }
    
    let everage = total / count
    printInfo("평균값: \(everage)")
}

func makeLuckyCount(seed: Int = 1) -> [Int] {
    var random = [Int]()
    let range = 761...8_493_578//70_066_516
    let count = 1...5
    
    for _ in count {
        let number = Int.random(in: range, using: &randomGenerator)
        random.append(number)
    }
    
    return random
}


//try testLuckyMain()
//let luckyCount = [
//    761,
//    8_356_060,
//    5_676_684,
//    6_225_507,
//    8_493_578]
let luckyCount = makeLuckyCount(seed: 1)
print("\(luckyCount)")
maekLuckyNumber(luckyCount: luckyCount)

