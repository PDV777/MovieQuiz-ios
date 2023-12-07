import UIKit

private struct QuizStepViewModel {
    let image:UIImage
    let question:String
    let questionNumber:String
}

private struct QuizQuestion {
    let image:String
    let text:String
    let correctAnswer:Bool
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
    QuizQuestion(
        image: "The Dark Knight",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
    QuizQuestion(
        image: "Deadpool",
        text: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    override func viewDidLoad() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        show(quiz:convert(model: questions[currentQuestionIndex]))
        super.viewDidLoad()
    }
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   self.showNextQuestionOrResults()
               }
        } else {
            noButton.isEnabled = false
            yesButton.isEnabled = false
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   self.showNextQuestionOrResults()
               }
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
           showAlert()
         
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0
            noButton.isEnabled = true
            yesButton.isEnabled = true
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
   private func showAlert() {

       let alert = UIAlertController(title: "Раунд окончен!",
                                      message: "Ваш результат \(correctAnswers)/\(questions.count)",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Сыграть еще раз", style: .default){ _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.imageView.layer.borderWidth = 0
            let newGame = self.questions[self.currentQuestionIndex]
            let nGViewModel = self.convert(model: newGame)
            self.show(quiz: nGViewModel)
        })
        present(alert,animated: true)
    }


    @IBAction private func noButtonClicked(_ sender: Any) {
        
        
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
           
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    @IBAction private func yesButtonClicked(_ sender: Any) {
       
      
        
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
           
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
        show(quiz: convert(model: questions[currentQuestionIndex]))
        
        
    }
}











/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
