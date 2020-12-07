//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
    }
    
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
    
    func test_didFinishLoadingCommentsWithError_displaysLocalizedErrorMessageAndStopLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingComments(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("COMMENTS_VIEW_CONNECTION_ERROR")),
                                       .display(isLoading: false)])
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
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
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