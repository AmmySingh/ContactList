//
//  CLCreateGroupViewController.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit

class CLCreateGroupViewController: UIViewController {
    
    var imageData: Data?
    var barButton = UIButton()
    var title_Group = String()
    var selected_Group: GroupBy?
    var contactModel: [ContactUser]?
    var selected_ContactModel = Set<ContactUser>()
    @IBOutlet weak var barButton_Done: UIBarButtonItem!
    @IBOutlet weak var barButton_GroupIcon: UIBarButtonItem!
    @IBOutlet weak var tableView_ContactList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set screen title as group name.
        self.title = title_Group
        
        // Method to fetch contacts from core data.
        customizeUI()
        validateDoneButton()
        fetchContactsFromCoreData()
    }
    
    //MARK: Private methods.
    func customizeUI () {
        
        self.tableView_ContactList.tableFooterView = UIView()
        barButton = UIButton(type: .custom)
        
        if selected_Group != nil && selected_Group?.groupImage != nil {
            barButton.setImage(UIImage(data: selected_Group?.groupImage as! Data), for: UIControlState.normal)
        } else {
            barButton.setImage(UIImage(named: "DummyGroup"), for: UIControlState.normal)
        }
        
        barButton.addTarget(self, action: #selector(CLCreateGroupViewController.groupPhotoButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        barButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        barButton.setRadius(radius: barButton.frame.size.width/2)
        barButton.setBorderWidthAndColor(width: 1, color: COLORS.COLOR_RED)
        barButton_GroupIcon.customView = barButton
    }
    
    // Code to fetch contacts from core data.
    func fetchContactsFromCoreData() {
        
        // Do any additional setup after loading the view.
        CLCoreDataManager.fetchContactsNotInGroup(groupObject: selected_Group) { (result, status) in
            
            if status {
                if result.count > 0 {
                    contactModel = result as? [ContactUser]
                    
                    for each in contactModel! {
                        
                        if each.groupRelationship != nil {
                            selected_ContactModel.insert(each)
                        }
                    }
                    
                    // Reload tableview.
                    tableView_ContactList.reloadData()
                }
            } else {
                CLUtility.showAlert(title: "Failure! Something happend wrong with local storage.")
            }
        }
    }
    
    func validateDoneButton() {
        
        if imageData != nil || selected_ContactModel.count > 0 {
            barButton_Done.isEnabled = true
        } else {
            barButton_Done.isEnabled = false
        }
    }
    
    func openPickerController (source: UIImagePickerControllerSourceType) {
        
        if !UIImagePickerController.isSourceTypeAvailable(source)  {
            if let topController = UIApplication.shared.keyWindow?.rootViewController {
                let alert = UIAlertController(title: "Sorry! Source not available.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                topController.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        DispatchQueue.main.async {
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = source
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: source)!
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    //MARK: IBAction methods.
    @IBAction func groupPhotoButtonPressed(_ sender: Any) {
        
        CLUtility.presentImagePickerAlert(controller: self) { (source) in
            self.openPickerController(source: source)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        CLCoreDataManager.saveGroup(groupObject: selected_Group, contactsSet: selected_ContactModel as NSSet, groupName: title_Group, groupIcon: imageData) { (status) in
            
            if status {
                self.performSegue(withIdentifier: "unwindToGroupsList", sender: self)
                _ = self.navigationController?.popViewController(animated: true)
                // CLUtility.showAlert(title: "Saved successfully!")
            } else {
                CLUtility.showAlert(title: "Failure! Something happend wrong.")
            }
        }
    }
    
    //MARK: Memory management.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: UITableViewDelegate and DataSource
extension CLCreateGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if contactModel == nil || contactModel?.count == 0 {
            
            var message: String?
            
            CLCoreDataManager.fetchContactsCount(completion: { (count) in
                
                if count == 0 {
                    message = "No contacts exist.\nPlease create new contact."
                } else {
                    message = "Sorry! All contacts are managed in groups."
                }
            })
            
            tableView.backgroundView = CLUtility.showEmptyMessage(tableView, message: message!, color: UIColor.lightGray)
            return 0;
        } else {
            tableView.backgroundView = UIView()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine;
            return 1;
        }
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
        
        if (selected_ContactModel.contains(contact!)) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get cell.
        let cell = tableView.cellForRow(at: indexPath)
        
        // Deselect row.
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = contactModel?[indexPath.row]
        if (selected_ContactModel.contains(contact!)) {
            let index = selected_ContactModel.index(of: contact!)
            selected_ContactModel.remove(at: index!)
            cell?.accessoryType = .none
        } else {
            selected_ContactModel.insert(contact!)
            cell?.accessoryType = .checkmark
        }
        
        // Code to enable/disable done button.
        validateDoneButton()
    }
}

//MARK: UIImagePickerControllerDelegate
extension CLCreateGroupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        barButton.setImage(image, for: .normal)
        imageData = UIImageJPEGRepresentation(image, 1)!
        picker.dismiss(animated: true, completion: nil)
        validateDoneButton()
    }
}
