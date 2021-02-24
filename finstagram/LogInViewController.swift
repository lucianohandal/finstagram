//
//  LogInViewController.swift
//  finstagram
//
//  Created by Luciano Handal on 2/22/21.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
 
    @IBAction func login(_ sender: Any) {
        let username = userField.text ?? ""
        let password = passwordField.text ?? ""
        
        
        print("Will login with user \(username) password \(password)")
        

        
        let target = db.collection("users").document(username)
        target.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Document data: \(document.data().map(String.init(describing:)) ?? "nil")")
                let email = document.get("email") as! String
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    if let _eror = error {
                        print(_eror.localizedDescription )
                    }else{
                        self.userField.text = ""
                        self.passwordField.text = ""
                        print("\(String(describing: result)) logged in")
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    }
                }
                
            } else {
                print("Document does not exist")
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

}
