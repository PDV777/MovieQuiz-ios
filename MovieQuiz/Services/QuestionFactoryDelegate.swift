//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitry on 20.12.2023.
//
import UIKit
protocol QuestionFactoryDelegate:AnyObject {
    func didReceiveNextQuestion(question:QuizQuestion?)
}
