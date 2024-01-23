//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Dmitry on 27.12.2023.
//

import Foundation
struct BestGame:Codable {
    let correct: Int
    let total: Int
    let date: Date
}
extension BestGame: Comparable {
    static func < (lhs: BestGame, rhs: BestGame) -> Bool {
        lhs.accuracy < rhs.accuracy
    }
    private var accuracy: Double {
        guard total != 0 else {
            return 0
        }
        return Double(correct) / Double(total)
    }
}
