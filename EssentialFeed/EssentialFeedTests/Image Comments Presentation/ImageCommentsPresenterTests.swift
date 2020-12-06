//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct ImageCommentsViewModel {
    let comments: [ImageComment]
}

protocol ImageCommentsView {
    func display(_ viewModel: ImageCommentsViewModel)
}

struct ImageCommentsLoadingViewModel {
    let isLoading: Bool
}

protocol ImageCommentsLoadingView {
    func display(_ viewModel: ImageCommentsLoadingViewModel)
}

struct ImageCommentsErrorViewModel {
    let message: String?
    
    static var noError: ImageCommentsErrorViewModel {
        return ImageCommentsErrorViewModel(message: nil)
    }
}

protocol ImageCommentsErrorView {
    func display(_ viewModel: ImageCommentsErrorViewModel)
}

final class ImageCommentsPresenter {
    private let imageCommentsView: ImageCommentsView
    private let loadingView: ImageCommentsLoadingView
    private let errorView: ImageCommentsErrorView
    
    init(imageCommentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
        self.imageCommentsView = imageCommentsView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingComments() {
        errorView.display(.noError)
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingComments(with comments: [ImageComment]) {
        imageCommentsView.display(ImageCommentsViewModel(comments: comments))
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
    }
}

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
       
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingComments_displaysCommentsAndStopLoading() {
        let (sut, view) = makeSUT()
        
        let comments = [comment(), comment()]
        sut.didFinishLoadingComments(with: comments)
        
        XCTAssertEqual(view.messages, [.display(comments: comments), .display(isLoading: false)])
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func comment() -> ImageComment {
        return ImageComment(id: UUID(), message: "any", createdAt: Date(), username: "any")
    }

    private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(comments: [ImageComment])
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: ImageCommentsViewModel) {
            messages.append(.display(comments: viewModel.comments))
        }
        
        func display(_ viewModel: ImageCommentsLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ImageCommentsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
