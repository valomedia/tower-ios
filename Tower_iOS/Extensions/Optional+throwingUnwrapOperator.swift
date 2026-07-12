//
//  Optional+throwingUnwrapOperator.swift
//  Tower_iOS
//
//
//

import Foundation


// MARK: Optional

postfix operator .!?

// MARK: + throwingUnwrapOperator

extension Optional {

    /// Unwrap a value throwing an UnwrapError, if the value is nil.
    ///
    /// This is intended to be used in situations where the value can't reasonably be nil, but if for whatever reason
    /// it is, we still want to at least display an error instead of just crashing.  Don't use this in situations where
    /// the error can be nil during normal functioning of the app, since the thrown Error is unspecific and unhelpful.
    ///
    static postfix func .!?(_ optional: Optional) throws -> Wrapped {
        guard let wrapped = optional else { throw UnwrapError() }
        return wrapped
    }
}

// MARK: + UnwrapError

extension Optional {

    /// The Error thrown if the throwing unwrap operator encountered a nil value.
    ///
    struct UnwrapError: Error {}

}
