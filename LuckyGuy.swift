#!/usr/bin/swift -F ./

import Foundation
import RandomKit
import Rainbow

let dataFilePath = "/Users/name/Documents/lotto1-806.json"

struct LottoCollection: Codable {
    var lottos: [Lotto]
}

struct Lotto: Codable {
    var order: Int
    var number: [Int]
    var bonus: Int
}

typealias WinNumber = (number: [Int], bonus: Int)

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

func printWinBlink(_ string: String) {
    print("[Win]".green.blink.bold + " \(string)")
}


var winNumber: WinNumber? {
    var random = [Int]()

    for _ in count {
        let number = Int.random(in: range, using: &randomGenerator)
        if random.contains(number) {
            //printError("\(random) contains \(number)")
            return nil
        }
        random.append(number)
    }
    let bonus = Int.random(in: range, using: &randomGenerator)
    random.sort()
    
    if random.contains(bonus) {
        //printError("\(random) contains \(bonus)")
        return nil
    }
    
    return WinNumber(number: random, bonus: bonus)
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


    
func popEye(lotto: Lotto) {

    var repeatCount = 0
    var errorCount = 0
    var winCount = 0
    while true {
        guard let winNumber = winNumber else {
            errorCount += 1
            continue
        }
        repeatCount += 1
        
        if lotto.number == winNumber.number {
            winCount += 1
            printWinBlink("(\(winCount)) (\(repeatCount)) Matched Item: \(lotto)")
            break
        }
        
//        if 0 == repeatCount % 1000000 {
//            printInfo("repeat count: \(repeatCount)")
//            printInfo("error count: \(errorCount)")
//        }
    }
}

func main() throws {
    guard let lottoCollection = loadData() else {
        return
    }
    
    for lotto in lottoCollection.lottos {
        popEye(lotto: lotto)
    }
}

try main()


