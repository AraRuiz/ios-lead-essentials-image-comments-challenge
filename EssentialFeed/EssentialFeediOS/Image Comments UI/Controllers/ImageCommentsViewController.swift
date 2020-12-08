//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 29/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsViewControllerDelegate {
    func didRequestCommentsRefresh()
    func didRequestCancelLoad()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsErrorView, ImageCommentsLoadingView, ImageCommentsView {
    @IBOutlet private(set) public var errorView: ErrorView?
    
    public var tableModel = [ImageCommentCellController]() {
        didSet {
            guard Thread.isMainThread else {
                return DispatchQueue.main.async { [weak self] in self?.tableView.reloadData() }
            }
            
            self.tableView.reloadData()
        }

    }
    
    public var delegate: ImageCommentsViewControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.didRequestCancelLoad()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestCommentsRefresh()
    }
    
    public func display(_ viewModel: ImageCommentsViewModel) {
        tableModel = viewModel.comments.map { ImageCommentCellController(model: $0) }
    }
    
    public func display(_ viewModel: ImageCommentsLoadingViewModel) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.refreshControl?.update(isRefreshing: viewModel.isLoading)
            }
        }
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ImageCommentsErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view(in: tableView)
    }
}
