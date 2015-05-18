//
//  MainViewController.swift
//  Moodle Quiz
//
//  Created by SamsonZouPro on 14/11/27.
//  Copyright (c) 2014年 Haolin Zou. All rights reserved.
//

import UIKit

class NewEssayViewController: UIViewController,UITextFieldDelegate  {
    //@IBOutlet weak var mainView: UIView!
    // might be problems
    
    var data = [SQLRow]()
    let db = SQLiteDB.sharedInstance()
    
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var lastEditDateButtonItem: UIBarButtonItem!
    

    @IBOutlet var questionName: UITextField!
    @IBOutlet weak var questionText: UITextView!
    @IBOutlet var questionMark: UITextField!
    var editting:Int  = 0
    var selectRowId:Int = 1
    var questionArray:[String]!
    var tempName: String?
    var tempText: String?
    var tempMark: String?
    
    @IBAction func showLastEditDate(sender: AnyObject){
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        questionName.delegate = self
        //questionText.delegate = self
        questionMark.delegate = self
        // Do any additional setup after loading the view.
        var myColor : UIColor = UIColor( red: 204/255, green: 204/255, blue:204/255, alpha: 1.0 )
        questionName.layer.borderColor = myColor.CGColor
        questionName.layer.borderWidth = 1.0
        questionText.layer.borderColor = myColor.CGColor
        questionText.layer.borderWidth = 1.0
        questionMark.layer.borderColor = myColor.CGColor
        questionMark.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "idSelectViewController"{println("segue")}
        }

    func editMode(selectRowId:Int) 
    {
        editting = 1
        let data = db.query("SELECT * FROM quizs WHERE id='\(selectRowId)'")
        let row = data[0]
        //let result = db.execute("Select FROM quizs WHERE id='\(selectRowId)'")
        if var name = row["name"] {tempName = name.asString()}
        if var text = row["text"] {tempText = text.asString()}
        if var mark = row["mark"] {tempMark = mark.asString()}
        
        dispatch_async(dispatch_get_main_queue()) {
            self.questionName.text = self.tempName
            self.questionText.text = self.tempText
            self.questionMark.text = self.tempMark

        }
        
    }
    
    
    @IBAction func submitButton() {
        
        let db = SQLiteDB.sharedInstance()
        let qquestionName: String = questionName.text!
        let qquestionText: String = questionText.text!
        let tempMark: String = questionMark.text!
        var qquestionMark: Int = NSNumberFormatter().numberFromString(tempMark)!.integerValue
        if (qquestionMark < -100 || qquestionMark > 100){ qquestionMark = 100}
        let questionType = 1
        if (editting == 1){
            let sql = "UPDATE quizs SET type=\(questionType), name = '\(qquestionName)', text = '\(qquestionText)', mark = '\(qquestionMark)' WHERE id = '\(selectRowId)'"
            let rc = db.execute(sql)
            if rc != 0 {let alert = UIAlertView(title:"SQLiteDB", message:"Question Successfully Updated!", delegate:nil, cancelButtonTitle: "OK"); alert.show()
            }

        
        }
        else{
            let sql = "INSERT INTO quizs(type, name, text, mark) VALUES ('\(questionType)','\(qquestionName)','\(qquestionText)','\(qquestionMark)')"
            let rc = db.execute(sql)
            if rc != 0 {let alert = UIAlertView(title:"SQLiteDB", message:"New Question Successfully Saved!", delegate:nil, cancelButtonTitle: "OK"); alert.show()
            }

        }
            }
    
    //return delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func loadControl()
    {
       
            questionName.text = "hi"
        
    }
    
    
}
