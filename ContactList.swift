//
//  ContactList.swift
//  Rebeep
//
//  Created by Ankit Kumar on 06/07/21.
// Copyright © 2021 Ankit Kumar. All rights reserved.

import UIKit
import Contacts
import ContactsUI


class ContactList: NSObject {
    
    static let shared = ContactList()
    
    public var mobileContacts: [CNContact] = []
   // public var mobileContactsBeep: []
    
    private override init() {
        super.init()
    }
    
    
    /**
     Create Contacts json file and save CNContacts in array.
     
     - Parameters:
     ------
     */
    public func readyContactJsonFile(){
        
        DispatchQueue.main.async {
            var constactJson: PARAMS = ["contactlist": []]
            
            // `contacts` Contains all details of Phone Contacts
            self.mobileContacts = self.getContactFromCNContact()
            var contactsList: [PARAMS] = []
            
            for contact in self.mobileContacts {
                
                let phoneNumber: String = contact.phoneNumbers.first?.value.stringValue.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "") ?? "123"
                
                contactsList.append(["contactId": contact.identifier,
                                     "name": contact.givenName + " " + contact.familyName,
                                     "phoneNumber": phoneNumber as Any])
                
                print(contact.identifier)
                print(contact.givenName + " " + contact.familyName)
                print(phoneNumber as Any)
            }
           // contactsList.append(contentsOf: contactsList)
           // contactsList.append(contentsOf: contactsList)
            print(contactsList.count)
            constactJson["contactlist"] = contactsList
            
            if let jsonString = self.convertToJson(params: constactJson){
                self.saveContactToJsonFile(jsonString)
            }else{
                fatalError("convertToJson no")
            }
        }
    }
    
    /**
     Get saved Contacts json file
     
     - Parameters:
     ------
     
     - returns: Json file paths
     */
    public func getContactJsonFilePath()-> URL?{
        if let docmentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let jsonFileWithPath = docmentDir.appendingPathComponent("myContacts.json")
            return jsonFileWithPath
        }
        return nil
    }
    
    
    
    //MARK:- Private methods
    private func convertToJson(params: PARAMS)-> String?{
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let jsonText = String(data: jsonData, encoding: .utf8)
            
            if let jsText = jsonText{
                return jsText
            }else{
                return nil
            }
            
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func saveContactToJsonFile(_ jsonString: String){
        
        if let docmentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let jsonFileWithPath = docmentDir.appendingPathComponent("myContacts.json")
            
            do {
                try jsonString.write(to: jsonFileWithPath,
                                     atomically: true,
                                     encoding: .utf8)
            } catch let error {
                print(error)
            }
        }
    }
    
    
    private func getContactFromCNContact() -> [CNContact] {
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactGivenNameKey,
            CNContactMiddleNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey
        ] as [Any]
        
        //Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
                
            } catch {
                print("Error fetching results for container")
            }
        }
        return results
    }
}
