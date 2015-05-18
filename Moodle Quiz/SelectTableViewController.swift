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

class SelectTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
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
//        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
//            let selectRow = (data[indexPath.row])["id"]
//            let temp = selectRow!.asString()
//            selectRowId = NSNumberFormatter().numberFromString(temp)!.integerValue
//            println("selectRowId:\(selectRowId)")
//        }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            if segue.identifier == selectSegue {
                if let destination = segue.destinationViewController as? NewEssayViewController {
                    if let selectIndex = tableView.indexPathForSelectedRow()?.row {
                        let selectRow = (data[selectIndex])["id"]
                        let temp = selectRow!.asString()
                        selectRowId = NSNumberFormatter().numberFromString(temp)!.integerValue
                        destination.selectRowId = selectRowId
                        destination.editMode(selectRowId)
                        //println("\(selectRowId)")
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
        
        //let headerAttributes = ["version": "1.0", "encoding": "UTF-8"]
        // var questionAttributes = ["type" : "\(exportArray[0])"]
       // let header2 = exportMoodle.addChild(name:"?xml")
       // let header3 = header2.addChild(name:"???")
       // <?xml version="1.0" encoding="UTF-8"?>
        
        
        let quizBracket = exportMoodle.addChild(name:"quiz")
        
        let questionTypeBracket = quizBracket.addChild(name: "question", attributes:["type": "category"])
        let questionCategory = questionTypeBracket.addChild(name:"category")
        let questionCategoryText = questionCategory.addChild(name:"Text", value:"$system$/Default for System")
        
        let numberOfData = data.count
       
        
        
        //let exportingId = NSNumberFormatter().numberFromString(exportId)!.integerValue
        
//        
//        var tempId = data[0]["type"]
//        var exportId = tempId!.asString()
//        var exportType = identifyDataInfo(exportId)
//        
//        var tempName = data[0]["name"]
//        var exportName = tempName!.asString()

//        
//        var questionAttributes = ["type" : "\(exportType)"]
//        var questionBracket = quizBracket.addChild(name: "quiestion", attributes: questionAttributes )
//        var questionName = questionBracket.addChild(name: "name" )
//        var questionText = questionName.addChild(name:"text", value:"\(exportName)")
        
        
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
//        <answer fraction="0" format="moodle_auto_format">
//        <text>true</text>
//        <feedback format="html">
//        <text></text>
//        </feedback>
//        </answer>
//        

       // findExportData(0)
        println( quizBracket.xmlString)
        var helloooo = quizBracket.xmlString
        
        
        
        
        
        
        
        
        var sp = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        
        //循环出力取得路径
        for file in sp {
            println(file)
        }
        
        //设定路径
        var url: NSURL = NSURL(fileURLWithPath: "/Users/Shared/data.xml")!
        
        //定义可变数据变量
        var data2 = NSMutableData()
        //向数据对象中添加文本，并制定文字code
        
        data2.appendData(helloooo.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        //用data写文件
        data2.writeToFile(url.path!, atomically: true)
        
        //从url里面读取数据，读取成功则赋予readData对象，读取失败则走else逻辑
        if let readData = NSData(contentsOfFile: url.path!) {
            //如果内容存在 则用readData创建文字列
            println(NSString(data: readData, encoding: NSUTF8StringEncoding))
        } else {  
            //nil的话，输出空  
            println("Null")  
        }
        
        
        
        
        
        
        
    }
    
    func findExportData(count:Int){
        //let numberOfRows= data.count
        
       // for var index = 0; index < numberOfRows; ++index{
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
    
    
    
    
    //DELETE FROM table_name
    //WHERE [condition];
    //let sql = "INSERT INTO quizs(type, name, text, mark) VALUES ('\(typetype)','\(qquestionName)','\(qquestionText)','\(qqquestionMark)')"

//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
