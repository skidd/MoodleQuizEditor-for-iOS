//
//  SelectTableViewController.swift
//  Moodle Quiz
//
//  Created by SamsonZouPro on 14/11/27.
//  Copyright (c) 2014年 Haolin Zou. All rights reserved.
//

//type id represent diffent type of questions: 1.Essay 2.True/False 3.Multiple Choice
//SegueAcution "idEditEssay"
import UIKit
import MessageUI

class SelectTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
        @IBOutlet var table:UITableView!
        @IBOutlet weak var searchTextField: UITextField!
        var data = [SQLRow]()
        let db = SQLiteDB.sharedInstance()
        var selectSegue = "idEditEssay"
    
        var selectRowId: Int = 0
        var selectRowType: Int = 1
        var exportArray = Array(count:4,repeatedValue:"0")
    
        override func viewDidLoad() {
            super.viewDidLoad()
            var refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: Selector("dataChanges"), forControlEvents: UIControlEvents.ValueChanged)
            self.refreshControl = refreshControl
        }
    
        func dataChanges() {
            readFromQuery()
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1;
        }
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            print("hi")
            readFromQuery()
            print("readed")
            table.reloadData()
        }
        func readFromQuery(){
            data = db.query("SELECT * FROM quizs ORDER BY name ASC")
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    
        override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
            let cnt = data.count
            return cnt
        }

    
        override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
            let cell:UITableViewCell = tv.dequeueReusableCellWithIdentifier("QuizCell") as! UITableViewCell
            let row = data[indexPath.row]
            if let quiz = row["name"] {
                cell.textLabel?.text = quiz.asString()
                if let quizType = row["type"]{
                cell.detailTextLabel?.text = self.findQuizType(quizType.asString())
                }
                
            }
          return cell
        }

    
    
        override func tableView(tv: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                let deleteRow = (data[indexPath.row])["id"]
                let deleteRowId = deleteRow!.asString()
                let rc = db.execute( "DELETE FROM quizs WHERE id='\(deleteRowId)'")
                println("3")
                table.reloadData()
                readFromQuery()
                tv.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
        }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            if segue.identifier == selectSegue {
                if let destination = segue.destinationViewController as? NewEssayViewController {
                    if let selectIndex = tableView.indexPathForSelectedRow()?.row {
                        let selectRow = (data[selectIndex])["id"]
                        let temp = selectRow!.asString()
                        selectRowId = NSNumberFormatter().numberFromString(temp)!.integerValue
                        destination.selectRowId = selectRowId
                        destination.editMode(selectRowId)
                
                    }
                }
            }
        
    }
    

    
    func findSegueType(){
        if let selectIndex = tableView.indexPathForSelectedRow()?.row {
            let selectRow = (data[selectIndex])["type"]
            let temp = selectRow!.asString()
            selectRowType = NSNumberFormatter().numberFromString(temp)!.integerValue
        }
        if(selectRowType == 1){selectSegue = "idEditEssay"}
        else if(selectRowType == 2){selectSegue = "idEditTf"}
        
    }
    
    @IBAction func exportButton(sender:AnyObject) {
        let exportMoodle = AEXMLDocument()
        
        let headerAttributes = ["version": "1.0", "encoding": "UTF-8"]
        var questionAttributes = ["type" : "\(exportArray[0])"]
        let headerOfXML = exportMoodle.addChild(name:"?xml",attributes:headerAttributes)

        
        
        let quizBracket = exportMoodle.addChild(name:"quiz")
        
        let questionTypeBracket = quizBracket.addChild(name: "question", attributes:["type": "category"])
        let questionCategory = questionTypeBracket.addChild(name:"category")
        let questionCategoryText = questionCategory.addChild(name:"Text", value:"$system$/Default for System")
        
        let numberOfData = data.count
        
        
        for var index = 0; index < numberOfData; ++index{
            findExportData(index)
            var questionAttributes = ["type" : "\(exportArray[0])"]
            var questionBracket = quizBracket.addChild(name: "question", attributes: questionAttributes )
            var questionName = questionBracket.addChild(name: "name" )
            var questionNameText = questionName.addChild(name:"text", value:"\(exportArray[1])")
            var questionTextAttributes = ["format":"html"]
            var questionText = questionBracket.addChild(name:"questiontext", attributes: questionTextAttributes)
            var questionTextText = questionText.addChild(name:"text", value:"\(exportArray[2])")
            
        }

        println( quizBracket.xmlString)
        var xmlcontent = quizBracket.xmlString
        
        
        var sp = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        
        for file in sp { println(file) }
        var docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var filePath = "\(docs)/data.xml"
        var url: NSURL = NSURL(fileURLWithPath: filePath)!
        
        var data2 = NSMutableData()
        
        data2.appendData(xmlcontent.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        data2.writeToFile(url.path!, atomically: true)
        
        if let readData = NSData(contentsOfFile: url.path!) {
            println(NSString(data: readData, encoding: NSUTF8StringEncoding))
        } else {
            println("Null")  
        }
        
        sendEmail(filePath, xmlcontent: xmlcontent)
        
    }
    
    
    
    func sendEmail(xmlPath:String, xmlcontent:String ) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            println("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Moodle XMl")
            mailComposer.setMessageBody(xmlcontent, isHTML: false)
            println(xmlPath)
            
            if let filePath = NSBundle.mainBundle().pathForResource(xmlPath, ofType: "xml") {
                println("File path loaded.")
                
                if let fileData = NSData(contentsOfFile: filePath) {
                    println("File data loaded.")
                    mailComposer.addAttachmentData(fileData, mimeType: "application/xml", fileName: "data")
                }
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func findExportData(count:Int){
            var tempId = data[count]["type"]
            var exportId = tempId!.asString()
            exportArray[0] = identifyDataInfo(exportId)
        
            var tempName = data[count]["name"]
            exportArray[1] = tempName!.asString()
        
            var tempText = data[count]["text"]
            exportArray[2] = tempText!.asString()
        
            var tempMark = data[count]["mark"]
            exportArray[3] = tempMark!.asString()
        
        
    }
    
    
    func identifyDataInfo(typeId:String) -> String{
        let quizType: String = "essay"
        if(typeId=="1"){ let quizType:String = "essay"; return quizType }
        else if(typeId=="2") { let quizType:String = "truefalse"; return quizType }
        return typeId
        
    }//for export type
    
    func findQuizType(typeId:String) -> String {
        let quizType: String = "Essay"
        if(typeId=="1"){ let quizType:String = "Essay"; return quizType }
        else if(typeId=="2") { let quizType:String = "True/False"; return quizType }
        return typeId
    }//for display in tableview, for better display
    
    
}
