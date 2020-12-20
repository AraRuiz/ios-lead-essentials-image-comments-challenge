//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class ImageCommentsUIComposer {
	public static func imageCommentsComposedWith(url: URL, loader: ImageCommentsLoader) -> ImageCommentsViewController {
		let adapter = ImageCommentsLoaderPresentationAdapter(url: url, imageCommentsLoader: MainQueueDispatchDecorator(decoratee: loader))
        let imageCommentsViewController = makeImageCommentsViewController(delegate: adapter)
        
        adapter.presenter = ImageCommentsPresenter(
            imageCommentsView: ImageCommentsViewAdapter(controller: imageCommentsViewController),
            loadingView: WeakRefVirtualProxy(imageCommentsViewController),
            errorView: WeakRefVirtualProxy(imageCommentsViewController)
        )
        
        return imageCommentsViewController
    }
    
    private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate) -> ImageCommentsViewController {
        let bundle = Bundle(for: ImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let imageCommentsViewController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
        imageCommentsViewController.delegate = delegate
        imageCommentsViewController.title = ImageCommentsPresenter.title
        return imageCommentsViewController
    }
}

private final class MainQueueDispatchDecorator: ImageCommentsLoader {
	let decoratee: ImageCommentsLoader
	
	init(decoratee: ImageCommentsLoader) {
		self.decoratee = decoratee
	}
	
	func loadComments(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
		return decoratee.loadComments(from: url) { result in
			guard Thread.isMainThread else {
				return DispatchQueue.main.async { completion(result) }
			}
			completion(result)
		}
	}
}
