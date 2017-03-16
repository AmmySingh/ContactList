//
//  CLUtility.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit

//var CompletionHandler: ((_ image: UIImage) -> Void)?

class CLUtility: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    
    class func presentImagePickerAlert(controller: UIViewController, completion: @escaping (_ source: UIImagePickerControllerSourceType) -> Void)  {
        
        let alert = UIAlertController(title: "Select photo from", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .destructive, handler: { (action) in
            
            completion(.camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            completion(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func showAlert(title: String) {
        
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    class func isTextEmpty(text: String) -> Bool {
        
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
    
    class func getTrimmedText(text: String) -> String {
        
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    class func showEmptyMessage(_ tableView: UITableView, message: String, color: UIColor) -> UIView {
        
        let labelMessage = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        
        labelMessage.text = message
        labelMessage.textAlignment = NSTextAlignment.center
        labelMessage.sizeToFit()
        labelMessage.textColor = color
        labelMessage.numberOfLines = 0
        tableView.backgroundView = labelMessage;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        return tableView.backgroundView!
    }
}

