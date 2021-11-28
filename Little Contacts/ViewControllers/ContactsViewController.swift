//
//  ContactsViewController.swift
//  Little Contacts
//
//  Created by Renzo Paul Chamorro on 27/11/21.
//

import UIKit
import Firebase
import SDWebImage

class ContactsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var contacts: [Contact] = []

        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.delegate = self
        loadContacts()
    }
    
    func loadContacts() {
        
        db.collection("contacts")
            .order(by: "name")
            .addSnapshotListener { (querySnapshot, error) in
            
            self.contacts = []
            
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let contactName = data["name"] as? String,
                           let contactNumber = data["number"] as? String,
                           let contactAvatarUrl = data["avatarUrl"] as? String {
                            let newContact = Contact(name: contactName, number: contactNumber, avatarUrl: contactAvatarUrl)
                            self.contacts.append(newContact)
                            
                            DispatchQueue.main.async {
                                   self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.contactNameLabel.text = contact.name
        cell.contactNumberLabel.text = contact.number
        cell.avatarImage.sd_setImage(with: URL(string: contact.avatarUrl), completed: nil)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

           let delete = UITableViewRowAction(style: .default, title: "Borrar") { (action, indexPath) in
               let currentContact = self.contacts[indexPath.row]
               self.view.activityStartAnimating(activityColor: .brown, backgroundColor: .clear)
               self.db.collection("contacts").document(currentContact.name).delete() { err in
                   if let err = err {
                       self.view.activityStopAnimating()
                       print("Error removing document: \(err)")
                   } else {
                       self.view.activityStopAnimating()
                       print("Document successfully removed!")
                       self.tableView.reloadData()
                   }
               }
            }
            delete.backgroundColor = UIColor.red

            let complete = UITableViewRowAction(style: .default, title: "Editar") { (action, indexPath) in
                let currentContact = self.contacts[indexPath.row]
                let alertController = UIAlertController(title: "Editar Contacto",
                                                        message: "Ingrese nuevo número",
                                                        preferredStyle: .alert)
                alertController.addTextField { (textField) in
                    textField.placeholder = "Nuevo número"
                    textField.keyboardType = .phonePad
                }
                
                let continueAction = UIAlertAction(title: "Guardar",
                                                   style: .default) { [weak alertController] _ in
                                                    guard let textFields = alertController?.textFields else { return }
                                                    
                                                    if let numberText = textFields[0].text {
                                                        print("Nuevo número: \(numberText)")
                                                        self.view.activityStartAnimating(activityColor: .brown, backgroundColor: .clear)
                                                        self.db.collection("contacts").document(currentContact.name).setData([
                                                            "name": currentContact.name,
                                                            "number": numberText,
                                                            "avatarUrl": currentContact.avatarUrl
                                                        ]) { (error) in
                                                            if let e = error {
                                                                self.view.activityStopAnimating()
                                                                print("There was an issue saving data to firestore, \(e)")
                                                            } else {
                                                                self.view.activityStopAnimating()
                                                                print("Successfully saved data.")
                                                            }
                                                        }
                                                        
                                                    }
                }
                let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(continueAction)
                self.present(alertController,
                             animated: true)
            }
            complete.backgroundColor = UIColor.blue

            return [delete, complete]
        }
}
