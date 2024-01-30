import UIKit
final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate {
    // MARK: - Lifecycle
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol? = nil
    private var currentQuestion:QuizQuestion?
    private var alertPresenter:AlertPresenter?
    private var statisticService: StatisticService?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        showLoadingIndicator()
        statisticService = StatisticServiceImpl(userDefaults: UserDefaults())
        alertPresenter = AlertPresenterImpl(viewController: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate:self)
        questionFactory?.loadData()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        super.viewDidLoad()
    }
    
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
    func didLoadDatFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
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
            let quizResultsViewModel = makeQuizResultsViewModel()
            showAlert(quiz: quizResultsViewModel)
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0
            noButton.isEnabled = true
            yesButton.isEnabled = true
            questionFactory?.requestNextQuestion()
        }
    }
    private func makeQuizResultsViewModel() -> QuizResultsViewModel {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        let gamesCount = statisticService?.gameCount ?? 0
        let staticAccuracy = statisticService?.totalAccuracy ?? 0
        guard let bestGame = statisticService?.bestGame else {
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
        let buttonText = "Сыграть еще раз"
        return QuizResultsViewModel(title: title, text: text, buttonText: buttonText)
    }
    private func showAlert(quiz: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: quiz.title,
            message: quiz.text,
            buttonText: quiz.buttonText,
            buttonAction: { [weak self] in
                self?.resetQuiz()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.layer.borderWidth = 0
        questionFactory?.requestNextQuestion()
    }
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message:String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз",
                               buttonAction:  { [weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            
            self?.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.show(alertModel: model)
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

