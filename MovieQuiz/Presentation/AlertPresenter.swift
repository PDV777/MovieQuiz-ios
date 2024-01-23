//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry on 24.12.2023.
//

import UIKit
protocol AlertPresenter {
    func show(alertModel: AlertModel)
}
final class AlertPresenterImpl {
    private weak var viewController:UIViewController?
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
}
extension AlertPresenterImpl:AlertPresenter {
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertModel.buttonText, style: .default) { [ alertModel] _ in
            alertModel.buttonAction()
        })
        viewController?.present(alert,animated: true)
    }
}

