//
//  SecondViewController.swift
//  GeckoDrivelog
//
//  Created by Nils Kleinert on 23.12.18.
//  Copyright © 2018 Nils Kleinert. All rights reserved.
//

import UIKit
import CoreLocation


struct cellData {
    var title = String()
    var subtitle = String()
    //var databaseId = Int64()
}

class TableViewController: UITableViewController {
    static var tableViewData = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 1
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 2
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("new count!")
        return TableViewController.tableViewData.count
    }
    
    // 3
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItem", for: indexPath)
        cell.textLabel?.text = TableViewController.tableViewData[indexPath.row].title
        cell.detailTextLabel?.text = TableViewController.tableViewData[indexPath.row].subtitle
        return cell
    }
    
    // 4
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog(TableViewController.tableViewData[indexPath.row].title)
    }
    
    func InsertHistory(locations: [CLLocationCoordinate2D ], meters: Double, title: String) {
        print(title)
        print("\(Double(String(format: "%.3f", meters / 1000)) ?? 0) Kilometer")
        TableViewController.tableViewData.insert(cellData(title: title, subtitle: "\(Double(String(format: "%.3f", meters / 1000)) ?? 0) Kilometer"), at: 0)
        print(TableViewController.tableViewData.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

}

