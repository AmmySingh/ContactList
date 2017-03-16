//
//  CLContactsViewController.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit
import Contacts
import CoreData

class CLContactsViewController: UIViewController {
    
    var contactModel: [ContactUser]?
    @IBOutlet weak var tableView_ContactList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Method calling.
        customizeUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            // Method to fetch contacts from core data.
            self.fetchContactsFromCoreData(canSaveContacts: true)
        }
    }
    
    //MARK: Private methods.
    func customizeUI() {
        
        self.tableView_ContactList.tableFooterView = UIView()
    }
    
    // Code to save phonebook contacts in core data.
    func savePhoneBookContactsInCoreData () {
        
        let con = CLPhoneBookManager()
        print(con.contacts)
        
        for each in con.contacts {
            
            let fName   = each.givenName
            let lName   = each.familyName
            var pNumber = String()
            let imageData = each.thumbnailImageData
            
            for phone in each.phoneNumbers {
                if phone.value.stringValue.characters.count > 0 {
                    pNumber = phone.value.stringValue
                    break
                }
            }
            
            CLCoreDataManager.saveContact(contactObject: nil,fName: fName, lName: lName, pNumber: pNumber, userImage: imageData) { (status) in
                
                if status {
                    print("Saved")
                } else {
                    CLUtility.showAlert(title: "Failure! Something happend wrong.")
                }
            }
        }
        
        // Get all contacts after fetched from phonebook.
        fetchContactsFromCoreData(canSaveContacts: false)
        
        /*let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         let docURL = urls[urls.endIndex-1]
         /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
         let storeURL = docURL.appendingPathComponent("ContactsList.sqlite")
         print(storeURL)*/
        
    }
    
    // Code to fetch contacts from core data.
    func fetchContactsFromCoreData(canSaveContacts: Bool) {
        
        // Do any additional setup after loading the view.
        CLCoreDataManager.fetchContacts { (result, status) in
            
            if status {
                if result.count > 0 {
                    
                    if contactModel != nil {
                        contactModel?.removeAll()
                    }
                    
                    contactModel = result as? [ContactUser]
                    
                    // Reload tableview.
                    tableView_ContactList.reloadData()
                } else {
                    
                    if canSaveContacts {
                        savePhoneBookContactsInCoreData()
                    }
                }
            }
        }
    }
    
    // Alert for the contact deletion cinfirmation.
    func showAlertForContactDeleteConfirmation(contact: ContactUser, indexPath: IndexPath) {
        
        let local_GroupRelationship: NSManagedObject = contact.groupRelationship!
        
        let fullName = contact.firstName! + contact.lastName!
        
        let alert = UIAlertController(title: "Do you really want to delete " + fullName, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // Delete contact here.
            CLCoreDataManager.delete(object: contact, completion: { (status) in
                
                if status {
                    self.contactModel?.remove(at: indexPath.row)
                    self.tableView_ContactList.deleteRows(at: [indexPath], with: .fade)
                    
                    // Sync group.
                    self.syncGroups(object: local_GroupRelationship)
                } else {
                    CLUtility.showAlert(title: "Failure! Contact not deleted.")
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func syncGroups (object: NSManagedObject) {
        
        CLCoreDataManager.checkIfOtherContactsContainInGroup(object: object) { (status) in
            
            // If status is false it means group dont have any contact. So delete the group
            if !status {
                
                // Delete group here.
                CLCoreDataManager.delete(object: object, completion: { (status) in
                    
                    if status {
                        let notificationName = Notification.Name("ReloadGroupsFromCoreData")
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    } else {
                        CLUtility.showAlert(title: "Failure! Group not deleted.")
                    }
                })
            } else {
                let notificationName = Notification.Name("ReloadGroupsFromCoreData")
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        }
    }
    
    //MARK: IBAction methods.
    // Unwind segue.
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
        print("unwindToContactsList")
        fetchContactsFromCoreData(canSaveContacts: false)
    }
    
    //MARK: Navigation segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE.CREATE_CONTACT {
            let controller = segue.destination as! CLCreateContactViewController
            controller.selected_Contact = sender as? ContactUser
        }
    }
    
    //MARK: Memory management.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: UITableViewDelegate and DataSource
extension CLContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if contactModel == nil || contactModel?.count == 0 {
            
            tableView.backgroundView = CLUtility.showEmptyMessage(tableView, message: "No contact found!\nPress + to create new contact.", color: UIColor.lightGray)
        } else {
            tableView.backgroundView = UIView()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine;
        }
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactModel != nil ? (contactModel?.count)!:0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let contact = contactModel?[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIERS.DETAILS_CELL) as! DetailsTableViewCell
        cell.label_Title.text   = (contact?.firstName)! + " " + (contact?.lastName)!
        cell.label_Numbers.text = contact?.phoneNumber
        
        if contact?.userImage != nil {
            cell.imageView_Photo.image = UIImage(data: contact?.userImage as! Data)
        } else {
            cell.imageView_Photo.image = UIImage(named: "DummyContact")
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get selected contact and navigate to create contact screen.
        let contact = contactModel?[indexPath.row]
        performSegue(withIdentifier: SEGUE.CREATE_CONTACT, sender: contact)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let contact = contactModel?[indexPath.row]
            showAlertForContactDeleteConfirmation(contact: contact!, indexPath: indexPath)
        }
    }
}
