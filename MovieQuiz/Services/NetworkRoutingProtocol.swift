//
//  NetworkRoutingProtocol.swift
//  MovieQuiz
//
//  Created by Dmitry on 31.01.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(url:URL,handler:@escaping(Result <Data,Error> )-> Void )
}
