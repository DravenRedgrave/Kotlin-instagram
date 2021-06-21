//
//  ViewController.swift
//  GooglePlacesSearch
//
//  Created by Michael Miles on 3/14/19.
//  Copyright © 2019 Michael Miles. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchInsetView: UIView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var searchTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var searchResults = [JSON]() {
        didSet {
            resultsTableView.reloadData()
        }
    }
    let apiFetcher = APIRequestFetcher()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        searchTextField.delegate = self
        
        resultsTableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    //MARK: TextField methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        searchTextFieldTopConstraint.constant = 10
        tableViewTopConstraint.constant = 65
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        self.searchLabel.isHidden = true
        self.resultsTableView.isHidden = false
        
        textField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchResults.removeAll()
        guard let textToSearch = textField.text, !textToSearch.isEmpty else {
            return
        }
        fetchResults(for: textToSearch)
    }
    
    func fetchResults(for text: String) {
        print("text searched: \(text)")
        apiFetcher.search(searchText: text, completionHandler: {
            [weak self] results, error in
            if case .failed = error {
                let alertController = UIAlertController(title: "Network Error", message: "Error connecting to network", preferredStyle: .alert)
                
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                
                alertController.addAction(actionOk)
                
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            guard let results = results, !results.isEmpty else {
                let alertController = UIAlertController(title: "Error", message: "Able to connect to network, but could not find results", preferredStyle: .alert)
                
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                
                alertController.addAction(actionOk)
                
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            self?.searchResults = results
        })
    }
    
    func setupUI() {
        searchTextField.leftView = searchInsetView
        searchTextField.leftViewMode = .always
    }
    
    //MARK: TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell
        
        cell.titleLabel.text = searchResults[indexPath.row]["structured_formatting"]["main_text"].stringValue
        cell.descriptionLabel.text = searchResults[indexPath.row]["structured_formatting"]["secondary_text"].stringValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToResult", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ResultViewController
        
        if let indexPath = resultsTableView.indexPathForSelectedRow {
            destinationVC.selectedPlace = searchResults[indexPath.row]["place_id"].stringValue
        }
    }

}

