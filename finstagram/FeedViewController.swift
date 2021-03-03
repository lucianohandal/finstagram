//
//  FeedViewController.swift
//  finstagram
//
//  Created by Luciano Handal on 2/22/21.
//

import UIKit
import AlamofireImage
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let ref = Database.database().reference()
    let post_limit = 20
    
    var posts = [[String : Any]]()
    var current_post: Int = 0
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let center =  NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
        posts.removeAll()
        db.collection("posts").order(by: "timestamp", descending: true).limit(to: post_limit).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("got \(querySnapshot!.documents.count) docs")
                
                for document in querySnapshot!.documents {
                    self.posts.append(document.data())
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = post["comments"] as! Array<[String : Any]>
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let post = posts[current_post]
        var post_comments = post["comments"] as! [[String : Any]]
        let text = commentBar.inputTextView.text
        guard let uid = Auth.auth().currentUser?.uid else {
                return
        }
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.dismiss(animated: true, completion: nil)
            } else {
                for document in querySnapshot!.documents {
                    let user = document.data()
                    guard let  username = user["username"] as? String else {
                        return
                    }
                    let post_id = self.posts[self.current_post]["id"] as! String
                    let comment_id = "\(post_id )c\(post_comments.count)"
                    let new_comment = ["author": username,
                                       "id": comment_id,
                                       "text": text!,
                                       "timestamp": NSDate()] as [String : Any]
                    self.db.collection("comments").document(comment_id).setData(new_comment)
                    post_comments.append(new_comment)
                    
                    self.db.collection("posts").document(post_id).setData([ "comments": post_comments ], merge: true)
                    self.posts[self.current_post]["comments"] = post_comments
                    self.tableView.reloadData()
                }
                
              }
            }
        
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = post["comments"] as! Array<[String : Any]>
        if indexPath.row == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostTableViewCell
            cell.postUser.text = post["user"] as? String
            cell.postCaption.text = post["caption"] as? String
            
            let storageRef = self.storage.reference()
            
            let postRef = storageRef.child("images/\(post["id"] ?? "default" ).png")

            postRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
              if let error = error {
                print("Error getting documents: \(error)")
              } else {
                let image = UIImage(data: data!)
                let size = CGSize(width: 374, height: 374)
                cell.postImage.image = image?.af.imageScaled(to: size)
              }
            }
        
        return cell
        } else if(indexPath.row <= comments.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! commentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            
            cell.commentAuthor.text = comment["author"] as? String
            cell.commentText.text = comment["text"] as? String
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCelll")!
        return cell
    }
    

    @IBAction func logout(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        current_post = indexPath.section
        let post = posts[current_post]
        let post_comments = post["comments"] as! [[String : Any]]
        print(indexPath.row, post_comments.count)
        if (indexPath.row ==  post_comments.count + 1){
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
        
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
    

    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
