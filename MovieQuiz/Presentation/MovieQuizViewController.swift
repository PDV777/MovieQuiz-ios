import UIKit
final class MovieQuizViewController: UIViewController,MovieQuizViewControllerProtocol {
    // MARK: - IBOutlets
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    // MARK: - Переменные сторонних сущностей
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter:AlertPresenter?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        alertPresenter = AlertPresenterImpl(viewController: self)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        super.viewDidLoad()
    }
    // MARK: - Private function
    
    private func resetQuiz() {
        presenter.restartGame()
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.layer.borderWidth = 0
    }
    // MARK: - Functions
    
    func show(quiz step:QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
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
            self?.presenter.restartGame()
            
        })
        alertPresenter?.show(alertModel: model)
    }
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            imageView.layer.borderWidth = 0
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    // MARK: - Actions
    
    @IBAction func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    @IBAction func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
}

