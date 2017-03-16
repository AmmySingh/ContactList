//
//  CLCreateContactViewController.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CLCreateContactViewController: UIViewController {
    
    var imageData: Data?
    var selected_Contact: ContactUser?
    
    @IBOutlet weak var label_AddPhoto: UILabel!
    @IBOutlet weak var imageView_User: UIImageView!
    @IBOutlet weak var textField_FName: UITextField!
    @IBOutlet weak var textField_LName: UITextField!
    @IBOutlet weak var textField_PNumber: UITextField!
    @IBOutlet weak var barButton_Done: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Method Calling
        customizeUI()
        initialization()
        validateDoneButton()
    }
    
    //MARK: Private Methods
    func customizeUI() {
        
        // Set label radius.
        label_AddPhoto.setRadius(radius: label_AddPhoto.frame.size.width/2)
        
        // Set label border color and width.
        label_AddPhoto.setBorderWidthAndColor(width: 1, color: COLORS.COLOR_RED)
        
        // Set image view radius.
        imageView_User.setRadius(radius: imageView_User.frame.size.width/2)
        
        // Add tap gesture on image view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CLCreateContactViewController.imageViewPressed(sender:)))
        imageView_User.isUserInteractionEnabled = true
        imageView_User.addGestureRecognizer(tapGesture)
    }
    
    func initialization () {
        
        if selected_Contact != nil {
            textField_FName.text = selected_Contact?.firstName
            textField_LName.text = selected_Contact?.lastName
            textField_PNumber.text = selected_Contact?.phoneNumber
            
            if selected_Contact?.userImage != nil {
                imageData = selected_Contact?.userImage as Data?
                imageView_User.image = UIImage(data: (selected_Contact?.userImage)! as Data)
            }
        }
    }
    
    func validateDoneButton() {
        
        if selected_Contact != nil {
            
            if ((textField_FName.text == selected_Contact?.firstName) &&
                (textField_LName.text == selected_Contact?.lastName) &&
                (textField_PNumber.text == selected_Contact?.phoneNumber) && imageData == nil) {
                barButton_Done.isEnabled = false
            } else {
                barButton_Done.isEnabled = true
            }
        } else {
            if (CLUtility.isTextEmpty(text: textField_FName.text!) || CLUtility.isTextEmpty(text: textField_LName.text!) || CLUtility.isTextEmpty(text: textField_PNumber.text!)) {
                barButton_Done.isEnabled = false
            } else {
                barButton_Done.isEnabled = true
            }
        }
    }
    
    func imageViewPressed(sender: UIGestureRecognizer) {
        
        CLUtility.presentImagePickerAlert(controller: self) { (source) in
            self.openPickerController(source: source)
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
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        let fName   = CLUtility.getTrimmedText(text: textField_FName.text!)
        let lName   = CLUtility.getTrimmedText(text: textField_LName.text!)
        let pNumber = CLUtility.getTrimmedText(text: textField_PNumber.text!)
        
        CLCoreDataManager.saveContact(contactObject: selected_Contact,fName: fName, lName: lName, pNumber: pNumber, userImage: imageData) { (status) in
            
            if status {
                self.performSegue(withIdentifier: "unwindToContactsList", sender: self)
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

//MARK: UITextFieldDelegate
extension CLCreateContactViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.keyboardType = textField == textField_PNumber ? .numberPad:.default
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = textField == textField_PNumber ? 19:100
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        validateDoneButton()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        validateDoneButton()
        return true
    }
}

//MARK: UIImagePickerControllerDelegate
extension CLCreateContactViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView_User.image = image
        label_AddPhoto.text  = ""
        imageData = UIImageJPEGRepresentation(image, 1)!
        picker.dismiss(animated: true, completion: nil)
        validateDoneButton()
    }
}
