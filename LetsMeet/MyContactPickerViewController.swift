//
//  MyContactPickerViewController.swift
//  LetsMeet
//
//  Created by Shruti  on 19/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

// This shows contactPicker with contact view and table view to show contacts selected by user
class MyContactPickerViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,MyContactPickerDelegate, ABPersonViewControllerDelegate {

   
    @IBOutlet var infoButton: UIBarButtonItem!
    var contactPickerView: MyContactPickerView?
    var contactsTableView: UITableView?
    
    var  contacts = [Contact]()  // All the contacts retrieved from CloudClient who have email Address and iCloud ID
    var  selectedContacts = [Contact]()
    var  filteredContacts = [Contact]()
    var selectedCount = 0
    
    var addressBook:ABAddressBook?
    
    let kKeyboardHeight:CGFloat = 216.0
    let kpickerViewHeight:CGFloat = 100.0
    let  contactPickerContactCellReuseID = "contactCell"
    var contactsLoadingActivityIndicator:UIActivityIndicatorView?
    var addContactBarButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addContactBarButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MyContactPickerViewController.getAllContacts(_:)))
        if AddressBookClient.sharedInstance().contactsRetrieved {
            navigationItem.rightBarButtonItem = addContactBarButton
            self.contacts = AddressBookClient.sharedInstance().contacts
        } else {
            contactsLoadingActivityIndicator  = UIActivityIndicatorView()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: contactsLoadingActivityIndicator!)
            contactsLoadingActivityIndicator!.startAnimating()
            navigationItem.prompt = "Loading contacts.."
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems?.append(infoButton)
        edgesForExtendedLayout = [UIRectEdge.bottom , UIRectEdge.left , UIRectEdge.right]
        
        // Initialize and add Contact Picker View
        let statusBarNavigationBarHeight:CGFloat = 0
        contactPickerView = MyContactPickerView(frame: CGRect(x: 0,y: statusBarNavigationBarHeight,width: self.view.frame.size.width, height: kpickerViewHeight))
        contactPickerView!.font = tableViewCellLabelFont()
        contactPickerView!.autoresizingMask = [UIViewAutoresizing.flexibleBottomMargin , UIViewAutoresizing.flexibleWidth]
        contactPickerView!.delegate = self
        contactPickerView!.setPlaceholderLabelText("Who would you like to invite?")
        contactPickerView!.setPromptLabelText("To:")
        view.addSubview(contactPickerView!)
        
        var layer = contactPickerView!.layer
        layer.shadowColor = UIColor(red: 225.0/255.0, green: 226.0/255.0, blue: 228.0/255.0, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 1.0
        
         if !AddressBookClient.sharedInstance().contactsRetrieved {
            contactPickerView!.textField?.isEnabled = false
        }
        
        // Fill the rest of the view with the table view
        contactsTableView = UITableView(frame: CGRect(
            x: 0,
            y: (contactPickerView!.frame.origin.y + contactPickerView!.frame.size.height),
            width: view.frame.size.width,
            height: view.frame.size.height -  statusBarNavigationBarHeight - contactPickerView!.frame.size.height), style: UITableViewStyle.plain)
         contactPickerView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth ,UIViewAutoresizing.flexibleHeight]
        contactsTableView!.delegate = self
        contactsTableView!.dataSource = self
        contactsTableView!.rowHeight = 60
        contactsTableView!.tableFooterView = UIView(frame: CGRect.zero)
        contactsTableView!.tableFooterView?.isHidden = true
        view.insertSubview(contactsTableView!, belowSubview: contactPickerView!)
        
        var cellNib = UINib(nibName: "ContactTableViewCell", bundle: nil)
        contactsTableView!.register(cellNib, forCellReuseIdentifier: contactPickerContactCellReuseID)
        
       contactsLoadingActivityIndicator?.color =  landingScreenFilledButtonTintColor()
        if !CloudClient.sharedInstance().canSearchForAddressbookContacts {
            contactsLoadingActivityIndicator?.stopAnimating()
            navigationItem.prompt = nil
            navigationItem.rightBarButtonItem = addContactBarButton
            contactPickerView!.textField?.isEnabled = true
            
        }
        if let userSelectedContacts = CloudClient.sharedInstance().meeting?.invitees  {
            for user in userSelectedContacts {
                selectedContacts.append(user)
                contactPickerView!.addContact(user)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        adjustTableViewFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(MyContactPickerViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyContactPickerViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyContactPickerViewController.contactsFetchedFromiCloud(_:)), name: NSNotification.Name(rawValue: AddressBookClient.sharedInstance().CONTACTSADDEDNOTIFICATION), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    // Show  contatcs of user having iCloud account
    func contactsFetchedFromiCloud(_ notification:Notification) {
        if let contactsAdded = notification.object as? Bool {
            if contactsAdded {
                if let activityIndicatorView = contactsLoadingActivityIndicator {
                    activityIndicatorView.stopAnimating()
                    self.contacts = AddressBookClient.sharedInstance().contacts
                    navigationItem.prompt = nil
                    navigationItem.rightBarButtonItem = addContactBarButton
                    contactPickerView!.textField?.isEnabled = true
                }
            }
        }
    }
    
    
    func adjustTableViewInsetTop(_ topInset:CGFloat, bottomInset:CGFloat) {
        contactsTableView!.contentInset = UIEdgeInsets(top: topInset, left: contactsTableView!.contentInset.left, bottom: bottomInset, right: contactsTableView!.contentInset.right)
        contactsTableView!.scrollIndicatorInsets = contactsTableView!.contentInset
    }
    
    func adjustTableViewFrame() {
       
        let yOffset = contactPickerView!.frame.origin.y + contactPickerView!.frame.size.height
        let tableFrame = CGRect(x: 0, y: yOffset, width: view.frame.size.width, height: view.frame.size.height - yOffset)
        contactsTableView!.frame = tableFrame;
    }
    
    func adjustTableViewInsetTop(_ topInset:CGFloat){
        adjustTableViewInsetTop(topInset, bottomInset: contactsTableView!.contentInset.bottom)
    }
    
    func adjustTableViewInsetBottom(_ bottomInset:CGFloat) {
        adjustTableViewInsetTop(contactsTableView!.contentInset.top, bottomInset:bottomInset)
    }

    
    //MARK:- UITableViewDelegate and DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get the desired contact from the filteredContacts array
        let contact = filteredContacts[(indexPath as NSIndexPath).row]
       
        // Initialize the table view cell
        
        var cell = tableView.dequeueReusableCell(withIdentifier: contactPickerContactCellReuseID) as? ContactTableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: contactPickerContactCellReuseID) as? ContactTableViewCell
        }
        
        cell!.fullNameLabel!.text = contact.fullName
        cell!.emailTypeLabel!.text = contact.emailLabel
        cell!.emailLabel!.text = contact.email
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
        
        // This uses the custom cellView
        let  user:Contact = filteredContacts[(indexPath as NSIndexPath).row]
       selectedContacts.contains(user)
        if selectedContacts.contains(user) {
            // contact is already selected so remove it from ContactPickerView
            selectedContacts = selectedContacts.filter({
                $0 != user
            })
            contactPickerView!.removeContact(user)
        }else {
            // Contact has not been selected, add it to THContactPickerView
            selectedContacts.append(user)
            contactPickerView!.addContact(user)
        }
        
        // Reset the filtered contactss
        filteredContacts = [Contact]()
        // Refresh the tableview
        contactsTableView!.reloadData()
    }
    
    //MARK:- ContactPickerTextViewDelegate
    
    func contactPickerTextViewDidChange(_ textViewText: String) {
        
        if textViewText == "" {
            
          self.filteredContacts  = [Contact]()
            
        } else {
        
             let predicate = NSPredicate(format: "self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", "firstName",textViewText,"lastName", textViewText)
            
            filteredContacts = contacts.filter({
                predicate.evaluate(with: $0)
            })
            
        }
        self.contactsTableView!.reloadData()
    }
    
    func contactPickerDidRemoveContact(_ contact: Contact) {
        selectedContacts = selectedContacts.filter({
            $0 != contact
        })
    }
    
    func contactPickerDidResize(_ contactPickerView: MyContactPickerView) {
       var frame = contactsTableView!.frame
       frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y
        contactsTableView!.frame = frame
        
    }
    
   
    func contactPickerTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    //MARK:-  Keyboard Methods
    
    func keyboardDidShow(_ notification:Notification) {
        
        let info = (notification as NSNotification).userInfo!
        
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let kbRect = view.convert(keyboardFrame , from: view.window!)
        
        adjustTableViewInsetBottom(contactsTableView!.frame.origin.y + contactsTableView!.frame.size.height - kbRect.origin.y)
    }
    
    func keyboardDidHide(_ notification:Notification) {
        
        
        let info = (notification as NSNotification).userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let kbRect = view.convert(keyboardFrame, from: view.window!)
        
        adjustTableViewInsetBottom(contactsTableView!.frame.origin.y + contactsTableView!.frame.size.height - kbRect.origin.y)

    }
    
    //MARK:- ABPersonViewControllerDelegate
    
    func personViewController(_ personViewController: ABPersonViewController!, shouldPerformDefaultActionForPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {
        return true
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
         dismiss(animated: true, completion: nil)
    }
    //MARK:- Take contacts and go ahead
    
    @IBAction func getAllContacts(_ sender: UIBarButtonItem) {
        if selectedContacts.count > 0 {
            CloudClient.sharedInstance().meeting?.invitees = selectedContacts
            print(self.selectedContacts)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showParticipantsInfoMessage(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Participants", message: "Your addressbook contacts who use this app and have iCloud id are shown here.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }

  

}
