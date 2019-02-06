//
//  PostListViewController.swift
//  Post
//
//  Created by XMS_JZhan on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {

    @IBOutlet weak var postTableView: UITableView!
    
    let postController = PostController()
    var refreshControl = UIRefreshControl.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.estimatedRowHeight = 45
        postTableView.refreshControl = refreshControl
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.addSubview(self.refreshControl)
        postController.fetchPosts(reset: true) {
            self.reloadTableView()
            print("Finished fetching from viewDidLoad")
        }
    }
    
    @objc func refreshControlPulled() {
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        postController.fetchPosts(reset: true) {
            DispatchQueue.main.async {
                //self.reloadTableView()
                self.refreshControl.endRefreshing()
                print("Finished fetching from refreshControlPulled")
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.postTableView.reloadData()
        }
    }
    
    func presentNewPostAlert() {
        let alert = UIAlertController(title: "New Post", message: "Please write your post...", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let userName = alert.textFields?[0].text, userName != "", let message = alert.textFields?[1].text, message != "" else {
                self.presentErrorAlert()
                return
            }
            self.postController.addNewPostWith(username: userName, text: message, completion: {
                print("Done")
                self.reloadTableView()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Username or message incorrect, please try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func addPostButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
}
// MARK: - Extension
extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView Data source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        cell.textLabel?.text = postController.posts[indexPath.row].text
        let username = postController.posts[indexPath.row].username
        let timestamp = postController.posts[indexPath.row].timestamp
        cell.detailTextLabel?.text = "\(username) \(timestamp)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row >= (postController.posts.count - 1)) {
            postController.fetchPosts(reset: false) {
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
    }
    
}
