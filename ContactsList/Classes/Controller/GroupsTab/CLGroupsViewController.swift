//
//  CLGroupsViewController.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit
import CoreData

class CLGroupsViewController: UIViewController {
    
    var groupModel: [GroupBy]?
    @IBOutlet weak var tableView_GroupList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Method calling.
        customizeUI()
        reginterNotification()
        fetchGroupsFromCoreData()
    }
    
    //MARK: Private methods.
    func customizeUI() {
        
        self.tableView_GroupList.tableFooterView = UIView()
    }
    
    func reginterNotification () {
        
        let notificationName = Notification.Name("ReloadGroupsFromCoreData")
        NotificationCenter.default.addObserver(self, selector: #selector(CLGroupsViewController.fetchGroupsFromCoreData), name: notificationName, object: nil)
    }
    
    // Code to fetch groups from core data.
    func fetchGroupsFromCoreData() {
        
        // Do any additional setup after loading the view.
        CLCoreDataManager.fetchGroups { (result, status) in
            
            if status {
                
                if groupModel != nil {
                    groupModel?.removeAll()
                }
                groupModel = result as? [GroupBy]
                
                // Reload tableview.
                tableView_GroupList.reloadData()
            } else {
                CLUtility.showAlert(title: "Failure! Something happend wrong with local storage.")
            }
        }
    }
    
    // Alert for the group deletion cinfirmation.
    func showAlertForGroupDeleteConfirmation(group: GroupBy, indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Do you really want to delete " + group.groupName!, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            print(group.objectID)
            
            // Delete group here.
            CLCoreDataManager.delete(object: group, completion: { (status) in
                
                if status {
                    self.groupModel?.remove(at: indexPath.row)
                    self.tableView_GroupList.deleteRows(at: [indexPath], with: .fade)
                } else {
                    CLUtility.showAlert(title: "Failure! Group not deleted.")
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: IBAction methods.
    @IBAction func addGroupButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Please enter group name.", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
            let date = NSDate()
            let calendar = NSCalendar.current
            let hour = calendar.component(.hour, from: date as Date)
            let minutes = calendar.component(.minute, from: date as Date)
            let seconds = calendar.component(.second, from: date as Date)
            textField.text = "Group " + "\(hour)" + ":" + "\(minutes)" + ":" + "\(seconds)"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            print(alert.textFields![0].text!)
            
            let title = CLUtility.getTrimmedText(text: alert.textFields![0].text!)
            if title.characters.count > 0 {
                
                self.performSegue(withIdentifier: SEGUE.CREATE_GROUP, sender: ["title":title, "group": NSNull()])
            } else {
                CLUtility.showAlert(title: "Please enter group name")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Unwind segue.
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
        print("unwindToGroupsList")
        fetchGroupsFromCoreData()
    }
    
    //MARK: Memory management.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE.CREATE_GROUP {
            
            let dict = sender as! Dictionary<String, Any>
            let controller = segue.destination as? CLCreateGroupViewController
            controller?.title_Group = dict["title"] as! String
            controller?.selected_Group = dict["group"] as? GroupBy
        }
    }
}

//MARK: UITableViewDelegate and DataSource
extension CLGroupsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if groupModel == nil || groupModel?.count == 0 {
            tableView.backgroundView = CLUtility.showEmptyMessage(tableView, message: "No group found!\nPress + to create new group.", color: UIColor.lightGray)
        } else {
            tableView.backgroundView = UIView()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        }
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupModel != nil ? (groupModel?.count)!:0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let group = groupModel?[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIERS.DETAILS_CELL) as! DetailsTableViewCell
        cell.label_Title.text = group?.groupName
        
        if group?.groupImage != nil {
            cell.imageView_Photo.image = UIImage(data: group?.groupImage as! Data)
        } else {
            cell.imageView_Photo.image = UIImage(named: "DummyGroup")
        }
        
        cell.label_Numbers.text = "\(group!.contactsCount)" + " contacts"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get selected group and navigate to create group screen.
        let group = groupModel?[indexPath.row]
        self.performSegue(withIdentifier: SEGUE.CREATE_GROUP, sender: ["title":group!.groupName!, "group": group!])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let group = groupModel?[indexPath.row]
            showAlertForGroupDeleteConfirmation(group: group!, indexPath: indexPath)
        }
    }
}
