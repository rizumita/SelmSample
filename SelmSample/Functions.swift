//
// Created by 和泉田 領一 on 2019-04-08.
// Copyright (c) 2019 CAPH TECH. All rights reserved.
//

import Foundation

func write<Item, Value>(_ keyPath: WritableKeyPath<Item, Value>) -> (@escaping (Value) -> Value) -> (Item) -> Item {
    return { update in
        return { item in
            var item = item
            item[keyPath: keyPath] = update(item[keyPath: keyPath])
            return item
        }
    }
}

func set<Item, Value>(_ keyPath: WritableKeyPath<Item, Value>, _ value: Value) -> (Item) -> Item {
    return (write(keyPath)) { _ in value }
}

func tee<Value, FunctionResult>(_ f: @escaping (Value) -> (FunctionResult)) -> (Value) -> Value {
    return { value in
        _ = f(value)
        return value
    }
}

func unwrap<A>(_ f: @escaping (A) -> ()) -> (A?) -> () {
    return { a in
        guard let a = a else { return }
        f(a)
    }
}

func tuplize<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A, B, C) -> D {
    return { a, b, c in f(a, b, c) }
}
