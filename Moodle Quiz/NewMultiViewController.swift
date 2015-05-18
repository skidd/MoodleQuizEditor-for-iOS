//
//  NewMultiViewController.swift
//  Moodle Quiz
//
//  Created by SamsonZouPro on 15/3/25.
//  Copyright (c) 2015年 Haolin Zou. All rights reserved.
//
//
//  MainViewController.swift
//  Moodle Quiz
//
//  Created by SamsonZouPro on 14/11/27.
//  Copyright (c) 2014年 Haolin Zou. All rights reserved.
//

import UIKit

class NewMultiViewController: UIViewController,UITextFieldDelegate  {
    @IBOutlet weak var mainView: UIView!
    // might be problems
    
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var lastEditDateButtonItem: UIBarButtonItem!
    
    
    @IBOutlet var questionName: UITextField!
    @IBOutlet var questionText: UITextField!
    @IBOutlet var questionMark: UITextField!
    var questionArray:[String]!
    
    @IBAction func showLastEditDate(sender: AnyObject){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionName.delegate = self
        questionText.delegate = self
        questionMark.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    
    @IBAction func submitButton() {
        
        let db = SQLiteDB.sharedInstance()
        println("1")
        let qquestionName: String = questionName.text!
        let qquestionText: String = questionText.text!
        let qquestionMark: String = questionMark.text!
        let qqquestionMark: Int = NSNumberFormatter().numberFromString(qquestionMark)!.integerValue
        let typetype = 1
        //        var qquestionMark: int {
        //            get{
        //                return NSNumberFormatter().numberFromString(questionMark.text)!.integerValue
        //            }
        //            set{
        //                self.text = questionMark.text
        //            }
        //        }
        //        let qquestionName = "q3"
        //        let qquestionText = "test3"
        //        let qquestionMark = 100
        
        let sql = "INSERT INTO quizs(type, name, text, mark) VALUES ('\(typetype)','\(qquestionName)','\(qquestionText)','\(qqquestionMark)')"
        
        
        //        let sql = "INSERT INTO quizs(typeID, quizName, quizText, mark) VALUES (1,'\(qquestionName)','\(qquestionText)','\(qquestionMark)')"x
        //println("2")
        let rc = db.execute(sql)
        //println("3")
        if rc != 0 {
            let alert = UIAlertView(title:"SQLiteDB", message:"Task successfully saved!", delegate:nil, cancelButtonTitle: "OK")
            alert.show()
           // println("4")
        }
    }
    
    //return delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
