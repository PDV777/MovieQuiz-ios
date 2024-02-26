//
//  PresenterTests.swift
//  MovieQuizTests
//
//  Created by Dmitry on 01.02.2024.
//

import Foundation
import XCTest
import UIKit
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showAlert(quiz: QuizResultsViewModel) {
    }
    func show(quiz step: QuizStepViewModel) {
    }
    func highlightImageBorder(isCorrectAnswer: Bool) {
    }
    func showLoadingIndicator() {
    }
    func hideLoadingIndicator() {
    }
    func showNetworkError(message: String) {
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        let questionText = "Question Text"
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: questionText, correctAnswer: true)
        let viewModel = sut.convert(model: question)
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, questionText)
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
