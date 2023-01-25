//
//  AsyncTransformable+Pipeline.swift
//  async-transform
//
//  Created by Joachim Kret on 25/01/2023.
//

import Foundation

extension AsyncTransformable {
    
    public func then<T: AsyncTransformable>(_ transformer: T) -> AsyncTransformer<Input, T.Output> where T.Input == Output {
        return then(transformer.transform(_:completion:))
    }
    
    public func then<U>(_ transform: @escaping (Output) throws -> U) -> AsyncTransformer<Input, U> {
        return then(MapTransformer(transform))
    }
    
    public func then<U>(_ nextTransform: @escaping AsyncTransformBlock<Output, U>) -> AsyncTransformer<Input, U> {
        return MapTransformer<Input, U>(pipeTransforms(transform(_:completion:), nextTransform))
    }
}

// MARK: Private

private func pipeTransforms<A, B, C>(
    _ lhs: @escaping AsyncTransformBlock<A, B>,
    _ rhs: @escaping AsyncTransformBlock<B, C>) -> AsyncTransformBlock<A, C>
{
    return { (value, completion) in
        let bag = CancelableBag()
        lhs(value) { result in
            switch result {
            case .success(let value):
                rhs(value, completion).append(into: bag)
            case .failure(let error):
                completion(.failure(error))
            }
        }.append(into: bag)
        return bag
    }
}
