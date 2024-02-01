import UIKit
final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate {
    // MARK: - IBOutlets
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet  var imageView: UIImageView!
    @IBOutlet  var yesButton: UIButton!
    @IBOutlet  var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    // MARK: - Переменные сторонних сущностей
    private let presenter = MovieQuizPresenter()
    var questionFactory: QuestionFactoryProtocol? = nil
    private var alertPresenter:AlertPresenter?
    private var statisticService: StatisticService?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        presenter.viewController = self
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
        presenter.didReceiveNextQuestion(question: question)
    }
    func didLoadDatFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func show(quiz step:QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            presenter.correctAnswers += 1
            noButton.isEnabled = false
            yesButton.isEnabled = false
            presenter.switchToNextQuestion()
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else {return}
                presenter.showNextQuestionOrResults()
            }
        } else {
            presenter.switchToNextQuestion()
            noButton.isEnabled = false
            yesButton.isEnabled = false
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else {return}
                presenter.showNextQuestionOrResults()
            }
        }
    }
    func showAlert(quiz: QuizResultsViewModel) {
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
    func resetQuiz() {
        presenter.resetQuestionIndex()
        presenter.correctAnswers = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.layer.borderWidth = 0
        questionFactory?.requestNextQuestion()
    }
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    func showNetworkError(message:String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз",
                               buttonAction:  { [weak self] in
            self?.presenter.resetQuestionIndex()
            self?.presenter.resetQuestionIndex()
            
            self?.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.show(alertModel: model)
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    @IBAction func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
}

