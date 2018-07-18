//
//  Store.swift
//  VManager
//
//  Created by meris on 2018-07-18.
//  Copyright © 2018 meris. All rights reserved.
//

import Foundation

typealias Listener<State> = (State) -> Void
typealias Reducer<State, Action> = (State, Action) -> State

class Store<State, Action> {
    private var state: State
    private var listeners: [Listener<State>] = []
    private let reducer: Reducer<State, Action>
    init(initialState: State, reducer: @escaping Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }
    func subscribe(listener: @escaping Listener<State>) {
        listeners.append(listener)
        listener(state)
    }
    func dispatch(action: Action) {
        state = reducer(state, action)
        listeners.forEach { (listener) in
            listener(state)
        }
    }
    func getState() -> State {
        return state
    }
}
