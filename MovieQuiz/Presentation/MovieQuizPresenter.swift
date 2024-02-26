//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry on 01.02.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService = StatisticServiceImpl(userDefaults: UserDefaults())
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion:QuizQuestion?
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    private func makeShow() -> QuizResultsViewModel {
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
        let isCorrect =  givenAnswer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        proceedWithAnswer(isCorrect: isCorrect)
    }
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let quizResultsViewModel = makeShow()
            self.viewController?.showAlert(quiz: quizResultsViewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
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
    func didLoadDatFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
}
