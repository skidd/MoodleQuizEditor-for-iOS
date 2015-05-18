//
//  NewTfViewController.swift
//  Moodle Quiz
//
//  Created by SamsonZouPro on 15/4/30.
//  Copyright (c) 2015年 Haolin Zou. All rights reserved.
//

import Foundation
import UIKit

class NewTfViewController: UIViewController,UITextFieldDelegate  {
    @IBOutlet weak var mainView: UIView!
    // might be problems
    
    var data = [SQLRow]()
    let db = SQLiteDB.sharedInstance()
    
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var lastEditDateButtonItem: UIBarButtonItem!
    
    
    @IBOutlet var questionName: UITextField!
    @IBOutlet var questionText: UITextView!
       @IBOutlet weak var questionAns: UISwitch!
    
    
    var editting:Int  = 0
    var selectRowId:Int = 1
    var questionArray:[String]!
    var tempName: String?
    var tempText: String?
    var tempAns: String?
    
    @IBAction func showLastEditDate(sender: AnyObject){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionName.delegate = self
        var myColor : UIColor = UIColor( red: 204/255, green: 204/255, blue:204/255, alpha: 1.0 )
        questionName.layer.borderColor = myColor.CGColor
        questionName.layer.borderWidth = 1.0
        questionText.layer.borderColor = myColor.CGColor
        questionText.layer.borderWidth = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "idTfViewController"{println("segue")}
    }
    
    
    func editMode(selectRowId:Int)
    {
        
    }
    
    
    @IBAction func submitButton() {
        
        let db = SQLiteDB.sharedInstance()
        let qquestionName: String = questionName.text!
        let qquestionText: String = questionText.text!
        let qquestionAns: Int = returnAns(questionAns)

        let questionType = 2
        if (editting == 1){
            let sql = "UPDATE quizs SET type=\(questionType), name = '\(qquestionName)', text = '\(qquestionText)', mark = '\(qquestionAns)' WHERE id = '\(selectRowId)'"
            let rc = db.execute(sql)
            if rc != 0 {let alert = UIAlertView(title:"SQLiteDB", message:"Question Successfully Updated!", delegate:nil, cancelButtonTitle: "OK"); alert.show()
            }
            
            
        }
        else{
            let sql = "INSERT INTO quizs(type, name, text, mark) VALUES ('\(questionType)','\(qquestionName)','\(qquestionText)','\(qquestionAns)')"
            let rc = db.execute(sql)
            if rc != 0 {let alert = UIAlertView(title:"SQLiteDB", message:"New Question Successfully Saved!", delegate:nil, cancelButtonTitle: "OK"); alert.show()
            }
            
        }
    }
    func returnAns(resultAns: UISwitch)-> Int{
        if(resultAns.on){return 100}
        return 0
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
}
}