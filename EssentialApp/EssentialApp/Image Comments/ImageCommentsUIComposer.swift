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
    public static func imageCommentsComposedWith(loader: @escaping () -> ImageCommentsLoader.Publisher) -> ImageCommentsViewController {
        let adapter = ImageCommentsLoaderPresentationAdapter(imageCommentsLoader: loader)
        
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
