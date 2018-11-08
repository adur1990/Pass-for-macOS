//
//  SafariExtensionViewController.swift
//  extension
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:330, height:22)
        return shared
    }()
    
    func popoverViewController() -> SafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    var resultsPasswords: [String]?
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var searchResultsTable: NSTableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBAction func searchPassword(_ sender: NSSearchField) {
        popoverViewController().resultsPasswords = sharedClientHandler.searchPasswords(searchString: sender.stringValue)
        popoverViewController().showSearchResults()
    }
    
    func showSearchResults() {
        let height = (self.resultsPasswords!.count * 20)
        popoverViewController().heightConstraint.animator().constant = CGFloat(height)
        
        var width = (resultsPasswords!.max(by: {$1.count > $0.count})?.count)! * 7
        if width < 330 {
            width = 330
        }
        popoverViewController().widthConstraint.animator().constant = CGFloat(width)
        
        popoverViewController().searchResultsTable.isHidden = false
        popoverViewController().searchResultsTable.reloadData()
        popoverViewController().searchResultsTable.selectRowIndexes(NSIndexSet(index: 0) as IndexSet, byExtendingSelection: true)
        popoverViewController().view.window?.makeFirstResponder(popoverViewController().searchResultsTable)
    }
    
    override func viewDidLoad() {
        popoverViewController().searchResultsTable.delegate = popoverViewController()
        popoverViewController().searchResultsTable.dataSource = popoverViewController()
        popoverViewController().searchResultsTable.target = self
        popoverViewController().searchResultsTable.doubleAction = #selector(tableViewDoubleClick(_:))
        popoverViewController().searchResultsTable.isHidden = true
    }
    
    func resetPopover() {
        popoverViewController().heightConstraint.animator().constant = CGFloat(0)
        popoverViewController().widthConstraint.animator().constant = CGFloat(330)
        popoverViewController().searchResultsTable.isHidden = true
    }
    
    func fillPasswordFromSelection() {
        guard popoverViewController().searchResultsTable.selectedRow >= 0,
            let item = popoverViewController().resultsPasswords?[popoverViewController().searchResultsTable.selectedRow] else {
                return
        }
        
        let credentials = sharedClientHandler.getPassword(passwordFile: item)?.components(separatedBy: "\n")
        let password = credentials![0]
        let login = credentials![1].split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines)
        SFSafariApplication.getActiveWindow { (window) in
            window!.getActiveTab { (activeTab) in
                activeTab!.getActivePage { (activePage) in
                    activePage!.dispatchMessageToScript(withName: "credentials", userInfo: ["password" : password, "login": login])
                }
            }
        }
        popoverViewController().dismiss(SafariExtensionViewController.shared)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 {
            fillPasswordFromSelection()
        }
    }
    
    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        fillPasswordFromSelection()
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
