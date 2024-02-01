//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry on 01.02.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    var statisticService = StatisticServiceImpl(userDefaults: UserDefaults())
    var currentQuestion:QuizQuestion?
    weak var viewController: MovieQuizViewController?
    let questionsAmount = 10
    private var currentQuestionIndex = 0
    var correctAnswers = 0
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
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
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let quizResultsViewModel = makeQuizResultsViewModel()
            self.viewController?.showAlert(quiz: quizResultsViewModel)
        } else {
            viewController?.imageView.layer.borderWidth = 0
            viewController?.noButton.isEnabled = true
            viewController?.yesButton.isEnabled = true
            viewController?.questionFactory?.requestNextQuestion()
        }
    }
        private func makeQuizResultsViewModel() -> QuizResultsViewModel {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let gamesCount = statisticService.gameCount
            let staticAccuracy = statisticService.totalAccuracy
            guard let bestGame = statisticService.bestGame else {
                assertionFailure("error message")
                return QuizResultsViewModel(title: "", text: "", buttonText: "")
            }
            let title = "Этот раунд окончен!"
            let text = """
                          Ваш результат: \(correctAnswers)/\(questionsAmount)
                          Количество сыгранных квизов: \(gamesCount)
                          Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
                          Средняя точность: \(String(format: "%.2f", staticAccuracy))%
                          """
            let buttonText = "Сыграть ещё раз"
            return QuizResultsViewModel(title: title, text: text, buttonText: buttonText)
        }
    private func didAnswer(isYes:Bool) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
}
