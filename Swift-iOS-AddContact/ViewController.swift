//
//  ViewController.swift
//  Swift-iOS-AddContact
//
//  Created by Rudi Luis on 11/02/15.
//  Copyright (c) 2015 Rudi Luis. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class ViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var firstName: UITextField!
  
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var number: UITextField!
    
    @IBOutlet weak var site: UITextField!
    
    @IBOutlet weak var street: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeReturnKeyAndDelegate()
    }
    
    func changeReturnKeyAndDelegate(){
        firstName.returnKeyType = UIReturnKeyType.Done
        firstName.delegate = self
        lastName.returnKeyType = UIReturnKeyType.Done
        lastName.delegate  = self
        email.returnKeyType = UIReturnKeyType.Done
        email.delegate = self
        number.returnKeyType = UIReturnKeyType.Done
        number.delegate = self
        site.returnKeyType = UIReturnKeyType.Done
        site.delegate = self
        street.returnKeyType = UIReturnKeyType.Done
        street.delegate = self
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func ActionButton(sender: UIButton) {
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            println("Already authorized")
            createContact()
        case .Denied:
            println("You are denied access to address book")
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {[weak self] (granted: Bool, error: CFError!) in
                    
                    if granted{
                        let strongSelf = self!
                        println("Access is granted")
                        strongSelf.createContact()
                    } else {
                        println("Access is not granted")
                    }
                    
            })
        case .Restricted:
            println("Access is restricted")
            
        default:
            println("Unhandled")
        }
        
       
    }
    
    
    
    func createContact(){
        
              newContact(firstName.text, lastName: lastName.text, email: email.text, number: number.text, site: site.text, personimage: self.imageView.image!, street: street.text, inAddressBook: addressBook)
        
        var alert = UIAlertController(title: "Informação", message: "O contacto foi adicionado!", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Fechar", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                print("")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        
    }

    
    func newContact(firstName: String,
        lastName: String,email: String,number : String,site : String, personimage : UIImage, street : String,
        inAddressBook: ABAddressBookRef) -> ABRecordRef?{
            
            let person: ABRecordRef = ABPersonCreate().takeRetainedValue()
            
           
            let imageData : CFData =  UIImageJPEGRepresentation(personimage, 0.7)
            
            ABRecordSetValue(person, kABPersonFirstNameProperty, firstName, nil)
            ABRecordSetValue(person, kABPersonLastNameProperty, lastName, nil)
            
            ABPersonSetImageData(person, imageData as CFDataRef, nil)
            
            ABRecordSetValue(person, kABPersonNoteProperty, street, nil)
            
            
            let couldSetEmail:ABMutableMultiValue = ABMultiValueCreateMutable(
                ABPropertyType(kABStringPropertyType)).takeRetainedValue()
            ABMultiValueAddValueAndLabel(couldSetEmail, email, kABWorkLabel, nil)
            ABRecordSetValue(person, kABPersonEmailProperty, couldSetEmail, nil)
            
            let couldSetNumber:ABMutableMultiValue = ABMultiValueCreateMutable(
                ABPropertyType(kABStringPropertyType)).takeRetainedValue()
            ABMultiValueAddValueAndLabel(couldSetNumber, number, kABPersonPhoneMobileLabel, nil)
            ABRecordSetValue(person, kABPersonPhoneProperty, couldSetNumber, nil)
            
            let couldSetSite:ABMutableMultiValue = ABMultiValueCreateMutable(
                ABPropertyType(kABStringPropertyType)).takeRetainedValue()
            ABMultiValueAddValueAndLabel(couldSetSite, site, kABPersonHomePageLabel, nil)
            ABRecordSetValue(person, kABPersonURLProperty, couldSetSite, nil)
            
            
            var error: Unmanaged<CFErrorRef>? = nil
            
            let couldAddPerson = ABAddressBookAddRecord(inAddressBook, person, &error)
            
            if couldAddPerson{
                println("Successfully added the person")
            } else {
                println("Failed to add the person.")
                return nil
            }
            
            if ABAddressBookHasUnsavedChanges(inAddressBook){
                
                var error: Unmanaged<CFErrorRef>? = nil
                let couldSaveAddressBook = ABAddressBookSave(inAddressBook, &error)
                
                if couldSaveAddressBook{
                    println("Successfully saved the address book")
                } else {
                    println("Failed to save the address book.")
                }
            }
            
            //    if couldSetFirstName && couldSetLastName{
            //      println("Successfully set the first name " +
            //          "and the last name of the person")
            //  } else {
            //     println("Failed to set the first name and/or " +
            //         "the last name of the person")
            // }
            
            return person
            
    }
    
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

