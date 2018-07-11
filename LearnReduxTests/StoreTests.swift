//
//  StoreTests.swift
//  LearnReduxTests
//
//  Created by Greg Kerzhner on 7/13/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation
import XCTest

@testable import LearnRedux

class StoreTests: XCTestCase {

  func testSubscription() {
    let subscriber = DummySubscriber()
    let subject = DummyStore(initialState: DummyState.reset, reducer: DummyReducer().reduce)

    subject.subscribe(subscriber)
    XCTAssert(subscriber.stateGotten?.count == 0)

    subject.dispatch(action: .decrement)

    XCTAssert(subscriber.stateGotten?.count == -1)

    subject.dispatch(action: .increment)
    subject.dispatch(action: .increment)

    XCTAssert(subscriber.stateGotten?.count == 1)
  }

  func testUnsubscription() {
    let subscriber = DummySubscriber()
    let subject = DummyStore(initialState: DummyState.reset, reducer: DummyReducer().reduce)

    subject.subscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -1)

    subject.unsubscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -1)

    subject.subscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -3)
  }

  func testNonRetain() {
    let exp = expectation(description: "exp")
    var subscriber: DummySubscriber! = DummySubscriber()
    subscriber.deinitCalled = {
       exp.fulfill()
    }
    let subject = DummyStore(initialState: DummyState.reset, reducer: DummyReducer().reduce)

    subject.subscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -1)

    DispatchQueue.global(qos: .background).async {
      subscriber = nil
    }

    waitForExpectations(timeout: 5)
  }

  func testViewModelSubscription() {
    let subscriber = DummySubscriber()
    let subject = DummyViewModel(initialState: DummyState.reset, reducer: DummyReducer().reduce)

    subject.subscribe(subscriber)
    XCTAssert(subscriber.stateGotten?.count == 0)
    XCTAssert(subscriber.isMainThread)

    subject.dispatch(action: .decrement)

    XCTAssert(subscriber.stateGotten?.count == -1)
    XCTAssert(subscriber.isMainThread)
    subject.dispatch(action: .increment)
    subject.dispatch(action: .increment)

    XCTAssert(subscriber.stateGotten?.count == 1)
    XCTAssert(subscriber.isMainThread)
  }

  func testViewModelUnsubscription() {
    let subscriber = DummySubscriber()
    let subject = DummyViewModel(initialState: DummyState.reset, reducer: DummyReducer().reduce)

    subject.subscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -1)

    subject.unsubscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -1)

    subject.subscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -3)
  }

  func testViewModelNonRetain() {
    let exp = expectation(description: "exp")
    var subscriber: DummySubscriber! = DummySubscriber()
    subscriber.deinitCalled = {
      exp.fulfill()
    }
    let subject = DummyViewModel(initialState: DummyState.reset, reducer: DummyReducer().reduce)

    subject.subscribe(subscriber)
    subject.dispatch(action: .decrement)
    XCTAssert(subscriber.stateGotten?.count == -1)

    DispatchQueue.global(qos: .background).async {
      subscriber = nil
    }

    waitForExpectations(timeout: 5)
  }

  class DummyStore: Store<DummyState, DummyAction> {}
  class DummyViewModel: ViewModel<DummyState, DummyAction> {}

  struct DummyReducer {
    func reduce(action: DummyAction, state: DummyState) -> DummyState {
      switch action {
      case .decrement: return DummyState(count: state.count - 1)
      case .increment: return DummyState(count: state.count + 1)
      }
    }
  }

  class DummySubscriber: StateSubscriber {
    var deinitCalled: (() -> Void)?
    deinit { deinitCalled?() }

    var stateGotten: DummyState?
    var isMainThread: Bool = false
    func newState(state: DummyState) {
      stateGotten = state
      isMainThread = Thread.isMainThread
    }
  }

  struct DummyState: StoreState {
    let count: Int

    static let reset = DummyState(count: 0)
  }

  enum DummyAction: StoreAction {
    case decrement
    case increment
  }
}
