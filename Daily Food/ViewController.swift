//
//  ViewController.swift
//  Daily Food
//
//  Created by Alyona Hulak on 6/12/18.
//  Copyright © 2018 Alyona Hulak. All rights reserved.
//
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    struct GlobalVariable {
       static var dishesForOurUser = [String]()
    }

    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    public var dayNumberOfWeek = 0
    private let service = GTLRSheetsService()
    public var userName = ""
    private var dayName = ""
    let signInButton = GIDSignInButton()
    let output = UITextView()
    let countOfDishes = 4
    public var dishesForOurUser = [String]()
    
    @IBOutlet weak var showMenu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        view.addSubview(signInButton)
        
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        //view.addSubview();
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            userName = user.profile.name
            dayNumberOfWeek = (Date().dayNumberOfWeek()! - 1)
            listMajors()
        }
    }

    func listMajors() {
        output.text = "Getting sheet data..."
        let spreadsheetId = "1danbKlgb13Rg52tCFEaQnpZRUcUq89D1fUEjfYkE7tI"
        var range = ""
        
        switch dayNumberOfWeek {
        case 1:
            range = "'Понедельник '!A2:M34"
            dayName = "Понедельник"
            showMenu.isHidden = false
        case 2:
            range = "'Вторник'!A2:M34"
            dayName = "Вторник"
            showMenu.isHidden = false
        case 3:
            range = "'Среда '!A2:M34"
            dayName = "Среда"
            showMenu.isHidden = false
        case 4:
            range = "'Четверг '!A2:M34"
            dayName = "Четверг"
            showMenu.isHidden = false
        case 5:
            range = "'Пятница '!A2:M34"
            dayName = "Пятница"
            showMenu.isHidden = false
        default:
            showAlert(title: "", message: "Сегодня выходной! :)")
        }
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        let rows = result.values!
        if rows.isEmpty {
            output.text = "No data found."
            return
        }
        
        var allDishes = rows[0]
        var dishesString = ""
        var dishesForSelectedUser = [String]()
        var users : [userInformation] = []
        var countOfColumns = 0;
        
        for column in 1...12 {
            dishesString += "\(allDishes[column]), "
        }
       
        for row in rows {
            dishesForSelectedUser = [dayName]
            let name = row[0]
            countOfColumns = 0
            for column in row {
                if ("\(column)") == "1" {
                    dishesForSelectedUser.append("\(allDishes[countOfColumns])")
                }
                countOfColumns += 1
            }
            let currentUser: userInformation = userInformation(name: "\(name)", dishes: dishesForSelectedUser)
            users.append(currentUser)
        }
        var flag = false
        for user in users {
            if user.name == userName {
                flag = true
                for dish in user.dishes {

                    dishesForOurUser.append("\(dish)")
                }
            }
        }
        GlobalVariable.dishesForOurUser = self.dishesForOurUser
        if (flag == false) {
            showAlert(title: "Упс 😅", message: "Вашего имени нет в таблице.")
        }
    }
    
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
