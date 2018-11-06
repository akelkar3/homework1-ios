//
//  AppsTableViewController.swift
//  iOSHW01
//
//  Created by Ankit Kelkar on 11/5/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//
import Alamofire
import SDWebImage
import UIKit
 var dataArray = [String:[AppObject]]()
class AppObject {
    var category :String!;
    var developer :String!;
    var link :String!;
    var otherImage :String!;
    var price :String!;
    var releaseDate :String!;
    var squareIcon :String!;
    var summary :String!;
    var title :String!;
    
    convenience init?(json: [String: Any]) {
        guard let cat = json["category"] as? String
            else {
                return nil
        }
        let dev = json["developer"] as? String
        let lin = json["link"] as? String
        let other = json["otherImage"] as? String
        let pri = json["price"] as? String
        let rel = json["releaseDate"] as? String
        let squ = json["squareIcon"] as? String
        let sum = json["summary"] as? String
        let tit = json["title"] as? String
        self.init(category:cat,developer:dev,link:lin,otherImage:other,releaseDate:rel, squareIcon:squ, price:pri,summary:sum,title:tit)
    }
    required init?(category: String, developer:String?,link:String?,otherImage:String?,releaseDate:String?,squareIcon:String?,price:String?,summary:String?,title:String?) {
        self.category = category
        self.developer = developer
        self.link = link
        self.otherImage = otherImage
        self.price = price
        self.releaseDate = releaseDate
        self.squareIcon = squareIcon
       self.summary = summary
       self.title = title
      //dataArray[self.category]?.append(self)
    }
}
class AppsTableViewController: UITableViewController {

    var data = ["Vegetables": ["Tomato", "Potato", "Lettuce"], "Fruits": ["Apple", "Banana"]]
    
   
    struct Objects {
        
        var sectionName : String!
        var sectionObjects : [AppObject]!
    }
    
    var objectArray = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapData()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 37
       
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return objectArray.count
        
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.darkGray
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objectArray[section].sectionObjects.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return objectArray[section].sectionName
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell
        let isSummary = objectArray[indexPath.section].sectionObjects[indexPath.row].summary != nil
        let isImage = objectArray[indexPath.section].sectionObjects[indexPath.row].otherImage != nil
        if isSummary {
            cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath)
             let summary:UILabel = cell.viewWithTag(6) as! UILabel
            summary.text = objectArray[indexPath.section].sectionObjects[indexPath.row].summary
        }
        else if isImage{
            cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
              let otherImage:UIImageView = cell.viewWithTag(7) as! UIImageView
            otherImage.sd_setImage(with: URL(string: objectArray[indexPath.section].sectionObjects[indexPath.row].otherImage), placeholderImage: UIImage(named: "placeholder.png"))
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "appcell", for: indexPath)
        }
        
        let name:UILabel = cell.viewWithTag(2) as! UILabel
        name.text = objectArray[indexPath.section].sectionObjects[indexPath.row].title
        let dev:UILabel = cell.viewWithTag(3) as! UILabel
        dev.text = objectArray[indexPath.section].sectionObjects[indexPath.row].developer
        
        let date:UILabel = cell.viewWithTag(4) as! UILabel
        date.text = getDateInFormat(indate: objectArray[indexPath.section].sectionObjects[indexPath.row].releaseDate)
        let price:UILabel = cell.viewWithTag(5) as! UILabel
        price.text = objectArray[indexPath.section].sectionObjects[indexPath.row].price
        let smallimage:UIImageView = cell.viewWithTag(1) as! UIImageView
      smallimage.sd_setImage(with: URL(string: objectArray[indexPath.section].sectionObjects[indexPath.row].squareIcon), placeholderImage: UIImage(named: "placeholder.png"))
        
//        if objectArray[indexPath.section].sectionObjects[indexPath.row].otherImage != nil {
//            summary.isHidden=true;
//            otherImage.sd_setImage(with: URL(string: objectArray[indexPath.section].sectionObjects[indexPath.row].otherImage), placeholderImage: UIImage(named: "placeholder.png"))
//
//        }else {
//            otherImage.isHidden=true
//        }
        return cell
      
    }
    func getDateInFormat(indate : String) -> String {
        let dateFormatterGet = DateFormatter()
        //    2011-11-17T00:00:00-07:00
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let date = dateFormatterGet.date(from: indate) {
            return dateFormatterPrint.string(from: date)
        } else {
            return "There was an error decoding the string"
        }
    }
    func mapData() -> Void {
        
        Alamofire.request("http://dev.theappsdr.com/apis/apps.json").responseJSON { response in
           
            if let json = response.result.value {
                
                print("data recieved") // serialized json response
                
                var data = response.result.value
              //  print("data\(data)")
            }
            guard let value = response.result.value as? [String: Any],
                let rows = value["feed"] as? [[String: Any]] else {
                    print("Malformed data received from fetchAllRooms service")
                    //completion(nil)
                    return
            }
            let apps = rows.map { json in
                return AppObject(json: json)
            }
            
            dataArray = Dictionary(grouping: apps, by: { $0!.category }) as! [String : [AppObject]]
           
            for (key, value) in dataArray {
                print("\(key) -> \(value)")
                self.objectArray.append(Objects(sectionName: key, sectionObjects: value))
            }
            self.tableView.reloadData()
           // completion(rooms)
        }
//
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }
        
    }
}



