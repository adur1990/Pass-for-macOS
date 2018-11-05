//
//  SafariExtensionViewController.swift
//  extension
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    var resultsPasswords: [String]?
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var searchResultsTable: NSTableView!
    
    @IBAction func searchPassword(_ sender: NSSearchField) {
        SafariExtensionViewController.shared.resultsPasswords = sharedClientHandler.searchPasswords(searchString: sender.stringValue)
        SafariExtensionViewController.shared.showSearchResults()
    }
    
    func showSearchResults() {
        let height = (self.resultsPasswords!.count * 20) + 22
        SafariExtensionViewController.shared.preferredContentSize = NSSize(width: 330, height: height)
        SafariExtensionViewController.shared.searchResultsTable.isHidden = false
        SafariExtensionViewController.shared.searchResultsTable.reloadData()
    }
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:330, height:22)
        return shared
    }()
    
    override func viewDidLoad() {
        let sharedViewController = SafariExtensionViewController.shared
        sharedViewController.searchResultsTable.delegate = sharedViewController
        sharedViewController.searchResultsTable.dataSource = sharedViewController
        sharedViewController.searchResultsTable.target = self
        sharedViewController.searchResultsTable.doubleAction = #selector(tableViewDoubleClick(_:))
        sharedViewController.searchResultsTable.isHidden = true
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        guard SafariExtensionViewController.shared.searchResultsTable.selectedRow >= 0,
            let item = SafariExtensionViewController.shared.resultsPasswords?[SafariExtensionViewController.shared.searchResultsTable.selectedRow] else {
                return
        }
        
        NSLog("########## \(item)")
        sharedClientHandler.getPassword(passwordString: item)
    }

}

extension SafariExtensionViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return SafariExtensionViewController.shared.resultsPasswords?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return (SafariExtensionViewController.shared.resultsPasswords!)[row]
    }
}
