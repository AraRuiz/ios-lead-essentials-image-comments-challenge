//
//  ImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 07/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoaderTask {
    func cancel()
}

public protocol ImageCommentsLoader {
    typealias Result = Swift.Result<[ImageComment], Error>
    
    func loadComments(completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask
}
