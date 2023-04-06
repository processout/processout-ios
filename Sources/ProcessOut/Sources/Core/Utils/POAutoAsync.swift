//
//  POAutoAsync.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

/// For types that implement this protocol, [Sourcery](https://github.com/krzysztofzablocki/Sourcery) will
/// automatically generate `async` methods for their callback-based counterparts. Only methods where last argument
/// is a closure that matches `(Result<?, Error>) -> Void` type are picked, see `Templates/AutoAsync.stencil` in
/// project's root directory for details.
public protocol POAutoAsync {}
