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
}

struct Contact {
    let name: String
    let number: String
    let avatarUrl: String
}
