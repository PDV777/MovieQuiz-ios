//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Dmitry on 27.12.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double {get}
    var gameCount:Int {get}
    var bestGame:BestGame? {get}
    func store(correct count:Int,total amount:Int)
}
final class StatisticServiceImpl {
    private enum Keys:String {
        case correct,
             total,
             bestGame,
             gamesCount
    }
    private let userDefaults:UserDefaults
    private let decoder:JSONDecoder
    private let encoder:JSONEncoder
    private let dateProvider: () -> Date
    init(userDefaults: UserDefaults,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder(),
         dateProvider: @escaping () -> Date = {Date() }
    ) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
        self.dateProvider = dateProvider
    }
}
extension StatisticServiceImpl: StatisticService {
    var gameCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.total.rawValue)
        }
    }
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.correct.rawValue)
        }
    }
    var bestGame: BestGame? {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let bestGame = try? decoder.decode(BestGame.self, from: data) else {
                return nil
            }
            return bestGame
        }
        set {
            let data = try? encoder.encode(newValue)
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    //Отвечает за добавление в историю сыгранных игр
    func store(correct: Int, total: Int) {
        self.correct += correct
        self.total += total
        self.gameCount += 1
        let date = dateProvider()
        let currentBestGame = BestGame(correct: correct, total: total, date: date)
        if let previousBestGame = bestGame {
            if currentBestGame > previousBestGame {
                bestGame = currentBestGame
            }
        } else {
            bestGame = currentBestGame
        }
    }
}

