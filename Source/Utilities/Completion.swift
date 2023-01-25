//
//  Completion.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

public typealias Completion<T> = (Result<T, Error>) -> Void
