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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let post_limit = 20
    
    var posts = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
        db.collection("posts").limit(to: post_limit).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("got \(querySnapshot!.documents.count) docs")
                for document in querySnapshot!.documents {
                    self.posts.append(document.data())
                    print("Hola", document.data())
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.postUser.text = post["user"] as? String
        cell.postCaption.text = post["caption"] as? String
        
        let storageRef = self.storage.reference()
        
        let postRef = storageRef.child("images/\(post["id"] ?? "default" ).png")

        postRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            print("Error getting documents: \(error)")
          } else {
//            cell.postImage.af_setImage(withURL: URL(string: post["downloadURL"] as! String))
            let image = UIImage(data: data!)
            let size = CGSize(width: 374, height: 374)
            cell.postImage.image = image?.af.imageScaled(to: size)
          }
        }
//        let url = URL(downloadURL)
        
        return cell
    }
    

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
