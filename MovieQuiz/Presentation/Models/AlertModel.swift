//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitry on 24.12.2023.
//

import Foundation

struct AlertModel {
    let title:String
    let message:String
    let buttonText:String
    let buttonAction: () -> Void
}


