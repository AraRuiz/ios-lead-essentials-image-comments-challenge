//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 09/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteImageCommentsLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result {
        case success([ImageComment])
        case failure(Error)
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadComments(from url: URL, completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentsLoader.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error as! RemoteImageCommentsLoader.Error)
        }
    }
}

private extension Array where Element == RemoteImageComment {
    func toModels() -> [ImageComment] {
        return map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, username: $0.author.username) }
    }
}



