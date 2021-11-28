//
//  AddContactViewController.swift
//  Little Contacts
//
//  Created by Renzo Paul Chamorro on 27/11/21.
//

import UIKit
import Firebase
import ConvenientImagePicker
import FirebaseStorage

class AddContactViewController: UIViewController {
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var numberTextfield: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!
    
    let db = Firestore.firestore()
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addContactTapped(_ sender: UIButton) {
        if let name = nameTextfield.text, let number = numberTextfield.text {
            if (name.count > 0 && number.count > 0) {
                self.view.activityStartAnimating(activityColor: .black, backgroundColor: .clear)
                let storageRef = Storage.storage().reference(forURL: "gs://little-contacts-6df1e.appspot.com")
                let storageAvatarRef = storageRef.child("avatars").child(name)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                let imageData = self.avatarImage.image?.jpegData(compressionQuality: 0.4)
                storageAvatarRef.putData(imageData!, metadata: metadata) { FIRStorageMetadata, error in
                    if error != nil {
                        self.view.activityStopAnimating()
                        print("error al subir imagen")
                        return
                    }
                    storageAvatarRef.downloadURL { url, error in
                        if let metaUrl = url?.absoluteString {
                            self.db.collection("contacts").document(name).setData([
                                "name": name,
                                "number": number,
                                "avatarUrl": metaUrl
                            ]) { (error) in
                                if let e = error {
                                    self.view.activityStopAnimating()
                                    print("There was an issue saving data to firestore, \(e)")
                                } else {
                                    self.view.activityStopAnimating()
                                    print("Successfully saved data.")
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }else {
                            self.view.activityStopAnimating()
                            print("error al obtener url de imagen")
                        }
                    }
                }
            } else {
                print("Error muy poca informacion")
            }
        }
    }
    @IBAction func pickImageTapped(_ sender: Any) {
        let pickerViewController = PickerViewController()
        pickerViewController.delegate = self
        pickerViewController.maxNumberOfSelectedImage = 1
        pickerViewController.allowMultipleSelection = false
        pickerViewController.isSupportLandscape = false
        self.present(pickerViewController, animated: true, completion: nil)
    }
    @IBAction func logOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            let alert = UIAlertController(title: "Error", message: signOutError.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension AddContactViewController: ConvenientImagePickerDelegate {
    func imagePickerDidCancel(_ selectedImages: [Int : UIImage]) {
    }
    
    func imageDidSelect(_ imagePicker: PickerViewController, index: Int, image: UIImage?) {
        if image != nil {
            self.avatarImage.image = image
        }
    }
    
    func imageDidDeselect(_ imagePicker: PickerViewController, index: Int, image: UIImage?) {
    }
    
    func imageSelectMax(_ imagePicker: PickerViewController, wantToSelectIndex: Int, wantToSelectImage: UIImage?) {
    }
    
    
}
