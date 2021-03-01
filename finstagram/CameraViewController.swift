//
//  CameraViewController.swift
//  finstagram
//
//  Created by Luciano Handal on 2/23/21.
//

import UIKit
import AlamofireImage
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func launchCamera(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 374, height: 374)
        let scaledImage = image.af.imageScaled(to: size)
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func shareBtn(_ sender: Any) {
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
                    var user_posts = user["posts"] as? Array<DocumentReference> ?? []
                    
                    let fileName = "\(username)\(user_posts.count)"
                    
                    let storageRef = self.storage.reference()
                    
                    guard let data = self.imageView.image?.pngData() else {
                        print("Image issue")
                        return
                    }
                    let postsRef = storageRef.child("images/\(fileName).png")
                    
                    _ = postsRef.putData(data, metadata: nil) { (metadata, error) in
                      guard let metadata = metadata else {
                        return
                      }
//                      let size = metadata.size
                        postsRef.downloadURL {
                            (url, error) in
                            guard let downloadURL = url else {
                                return
                            }
                            self.db.collection("posts").document(fileName).setData([
                                "user": username,
                                "uid": uid,
                                "id": fileName,
                                "downloadURL": "\(downloadURL)",
                                "caption": self.commentField.text ?? "",
                                "timestamp": NSDate()
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    print("Document added")
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                            user_posts.append(self.db.collection("posts").document(fileName))
                            self.db.collection("users").document(username).setData([ "posts": user_posts ], merge: true)
                        }
                    }
                    print(user_posts)
              }
            }
        }
        
    }
}
        
        

        


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


