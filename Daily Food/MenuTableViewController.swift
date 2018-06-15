//
//  MenuTableViewController.swift
//  Daily Food
//
//  Created by Alyona Hulak on 6/14/18.
//  Copyright © 2018 Alyona Hulak. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.GlobalVariable.dishesForOurUser.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
        cell.textLabel?.text = ViewController.GlobalVariable.dishesForOurUser[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }



}
