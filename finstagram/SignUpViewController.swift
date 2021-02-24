//
//  SignUpViewController.swift
//  finstagram
//
//  Created by Luciano Handal on 2/22/21.
//

import UIKit
import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signup(_ sender: Any) {
        let username = usernameField.text ?? ""
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        if (username == "") {
            print("username empty")
            return
        }
        
        if (email == "") {
            print("Email empty")
            return
        }
        
        if (password == "") {
            print("Password empty")
            return
        }
        
        if (password != confirmField.text){
            print("Passwords do not match")
            return
        }
        
        print("Will create an ccount for email \(email) with password \(password)")
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let _eror = error {
                print(_eror.localizedDescription )
            }else{
                let uid = Auth.auth().currentUser?.uid  ?? "null"
                let docData:[String: Any] = [
                    "email": email,
                    "username": username,
                    "uid": uid]
                
                self.db.collection("users").document(username).setData(docData) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        self.usernameField.text = ""
                        self.emailField.text = ""
                        self.confirmField.text = ""
                        self.passwordField.text = ""
                        self.performSegue(withIdentifier: "signupSegue", sender: nil)
                    }
                }
                print(result ?? "Success")
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
