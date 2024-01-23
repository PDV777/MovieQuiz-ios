import UIKit
final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // MARK: - Lifecycle
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol? = nil
    private var currentQuestion:QuizQuestion?
    private var alertPresenter:AlertPresenter?
    private var statisticService: StatisticService?
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    override func viewDidLoad() {
        statisticService = StatisticServiceImpl(userDefaults: UserDefaults())
        alertPresenter = AlertPresenterImpl(viewController: self)
        questionFactory = QuestionFactory(delegate:self)
        questionFactory?.requestNextQuestion()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        questionFactory?.requestNextQuestion()
        super.viewDidLoad()
    }
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    private func show(quiz step:QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            noButton.isEnabled = false
            yesButton.isEnabled = false
            correctAnswers += 1
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else {return}
                showNextQuestionOrResults()
            }
        } else {
            noButton.isEnabled = false
            yesButton.isEnabled = false
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else {return}
                showNextQuestionOrResults()
            }
        }
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let quizResultsViewModel = QuizResultsViewModel(title: "", text: "", buttonText: "")
            showAlert(quiz: quizResultsViewModel)
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0
            noButton.isEnabled = true
            yesButton.isEnabled = true
            questionFactory?.requestNextQuestion()
        }
    }
    private func showAlert(quiz:QuizResultsViewModel) {
        statisticService?.store(correct:correctAnswers , total: questionsAmount)
        let gamesCount = statisticService?.gameCount ?? 0
        let staticAccuracy = statisticService?.totalAccuracy ?? 0
        guard let bestGame = statisticService?.bestGame else {
            assertionFailure("error message")
            return
        }
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: """
                                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                                    Количество сыгранных квизов: \(gamesCount)
                                    Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
                                    Средняя точность: \(String(format: "%.2f", staticAccuracy))%
                                    """,
                                    buttonText: "Сыграть еще раз",
                                    buttonAction: { [weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.yesButton.isEnabled = true
            self?.noButton.isEnabled = true
            self?.imageView.layer.borderWidth = 0
            self?.questionFactory?.requestNextQuestion()
        }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    @IBAction func noButtonClicked(_ sender: Any) {   guard let currentQuestion = currentQuestion else {
        return
    }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

