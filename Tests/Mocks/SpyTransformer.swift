//
//  SpyTransformer.swift
//  AsyncTransform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation
import AsyncTransform

class SpyTransformer<Input, Output>: AsyncTransformable {
    typealias State = TransformerState<Input, Output>
    
    var onInvoked: ((Input) -> Void)?
    var onSuccess: ((Output) -> Void)?
    var onFailure: ((Error) -> Void)?
    var onCanceled: (() -> Void)?
    
    private(set) var state: State = .idle {
        didSet {
            notifyDidChange(form: oldValue, to: state)
        }
    }
    
    func transform(_ value: Input, completion: @escaping Completion<Output>) -> Cancelable {
        return set(
            transitionTo: .invoked(value, completion),
            then: { [weak self] in
                return AnyCancelable { self?.cancel() }
            }, otherwise: {
                return NoopCancelable()
            })
    }
    
    func resolve(with result: Result<Output, Error>) {
        switch result {
        case .success(let value): success(with: value)
        case .failure(let error): failure(with: error)
        }
    }
    
    func success(with value: Output) {
        setIfPossible(transitionTo: .success(value))
    }
    
    func failure(with error: Error = FakeError()) {
        setIfPossible(transitionTo: .failure(error))
    }
    
    func cancel() {
        setIfPossible(transitionTo: .canceled)
    }
    
    private func setIfPossible(transitionTo newState: State) {
        set(transitionTo: newState, then: { }, otherwise: { })
    }
    
    private func set<T>(
        transitionTo newState: State,
        then action: () -> T,
        otherwise: () -> T
    ) -> T {
        if canTransition(from: state, to: newState) {
            let oldState = state
            state = newState
            let value = action()
            handleCompleteIfInvoked(from: oldState, to: newState)
            return value
        } else {
            return otherwise()
        }
    }
    
    private func canTransition(from oldState: State, to newState: State) -> Bool {
        switch (oldState, newState) {
        case (.idle, .invoked): return true
        case (.invoked, .success): return true
        case (.invoked, .failure): return true
        case (.invoked, .canceled): return true
        default: return false
        }
    }
    
    private func handleCompleteIfInvoked(from oldState: State, to newState: State) {
        guard case .invoked(_, let completion) = oldState else {
            return
        }
        
        switch newState {
        case .success(let value): completion(.success(value))
        case .failure(let error): completion(.failure(error))
        case .canceled: completion(.failure(CancelError()))
        default: break
        }
    }
    
    private func notifyDidChange(form oldState: State, to newState: State) {
        switch newState {
        case .invoked(let value, _): onInvoked?(value)
        case .success(let value): onSuccess?(value)
        case .failure(let error): onFailure?(error)
        case .canceled: onCanceled?()
        default: break
        }
    }
}
