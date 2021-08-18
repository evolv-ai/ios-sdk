//
//  Combine+Extensions.swift
//  EvolvSwiftSDK
//
//  Created by Alim Yuzbashev on 18.08.2021.
//

import Combine

extension Subscribers.Completion {
    func resultRepresentation<T>(withSuccessCase successCase: T) -> Result<T, Failure> {
        let result: Result<T, Failure>
        
        switch self {
        case .finished:
            result = .success(successCase)
        case .failure(let error):
            result = .failure(error)
        }
        
        return result
    }
}
