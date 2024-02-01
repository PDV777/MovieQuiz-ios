//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry on 01.02.2024.
//

import UIKit

final class MovieQuizPresenter {
    var currentQuestion:QuizQuestion?
    weak var viewController: MovieQuizViewController?
    let questionsAmount = 10
    private var currentQuestionIndex = 0
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
func noButtonClicked() {
    guard let currentQuestion = currentQuestion else {
        return
    }
        let givenAnswer = false
    viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
