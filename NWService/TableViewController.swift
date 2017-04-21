//
//  TableViewController.swift
//  NWService
//
//  Created by TIMMARAJU SAI V on 4/14/17.
//  Copyright © 2017 OSU. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController,XMLParserDelegate {

    
    var cityZipCodes = ["74075","25414","98101","99501"];
    var cityNames = ["Stillwater,OK","Charles Town,MA","Seattle,WA","Anchorage,AL"];
    var maxTemperatues = [Int]();
    var temperatueImages = [UIImage]();
    var currentDate = ""
    var check = false
    var imageCheck = false
  
    func UIColorFromTemperature(temperature:Int) -> UIColor{
        let interpolatedValue:Double = (Double(temperature) - 32.0)/(90.0-32.0)
        let red = (0.117647*(1.0-interpolatedValue)+interpolatedValue*1.0)
        let green =  0.564706*(1-interpolatedValue) + interpolatedValue*0.270588
        let blue = 1.0*(1-interpolatedValue) + interpolatedValue*0.01
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue) , alpha: 1.0)
        
    }
    
    @IBAction func addNewZip(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Enter Zipcode", message: "", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: {
            alert->Void in
             let firstTextField = alertController.textFields![0] as UITextField
            
            if(!self.cityZipCodes.contains(firstTextField.text!) && (firstTextField.text?.characters.count)!>0)
            {
            
                let url:URL = URL(string : "http://api.zipasaur.us/zip/\(firstTextField.text!)")!
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.dataTask(with: url){ (data,response,error) in
                    //check to see any errors
                    guard error == nil else{
                        print("Error in session call:\(error)")
                        return
                    }
                    guard let result = data else {
                        print("No data received")
                        return
                    }
                    do{
                        let returnArray = try JSONSerialization.jsonObject(with: result, options: .allowFragments) as? NSDictionary
                        if returnArray != nil
                        {
                            self.cityNames.append((returnArray?["city"] as! String)+","+(returnArray?["state_abbrev"] as! String))
                        }
                        else
                        {
                            self.cityNames.append("")
                        }
                        self.cityZipCodes.append(firstTextField.text!)
                        self.retriveDataFromZip(firstTextField.text!)
                    }catch {
                        print("Error Serialization JSON Data\n\n")
                    }
                }
                task.resume();
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action:UIAlertAction!)->Void in
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.present(alertController,animated: true,completion: nil)
        
    }
    
    func retriveDataFromZip(_ zip:String)
    {
        let baseURL = "https://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?whichClient=NDFDgenByDayMultiZipCode&lat=&lon=&listLatLon=&lat1=&lon1=&lat2=&lon2=&resolutionSub=&endPoint1Lat=&endPoint1Lon=&endPoint2Lat=&endPoint2Lon=&centerPointLat=&centerPointLon=&distanceLat=&distanceLon=&resolutionSquare=&zipCodeList=\(zip)&citiesLevel=&format=24+hourly&startDate=\(currentDate)&numDays=1&Unit=e&Submit=Submit";
        
        let urlToSend:URL = URL(string: baseURL)!
        let parser = XMLParser(contentsOf: urlToSend)
        parser?.delegate = self
        parser?.parse()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        currentDate = formatter.string(from: Date())
        
        var concatenateAllZips = ""
        for eachZip in cityZipCodes
        {
            concatenateAllZips += eachZip + "+"
        }
        
        //removing extra last character in-place way
        concatenateAllZips.remove(at: concatenateAllZips.index(before: concatenateAllZips.endIndex))
        
        retriveDataFromZip(concatenateAllZips)

    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "temperature"
        {
            if(attributeDict["type"]=="maximum")
            {
                self.check = true;
            }
        }
        if elementName == "icon-link"
        {
            self.imageCheck = true
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "temperature"
        {
            self.check = false;
        }
        if elementName == "icon-link"
        {
            self.imageCheck = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if(self.check)
        {
            let num = Int(string)
            if num != nil
            {
                maxTemperatues.append(num!)
            }
        }
        if(self.imageCheck)
        {
       
            let url = URL(string: string)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            temperatueImages.append(UIImage(data: data!)!)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if cityZipCodes.count == maxTemperatues.count
        {
            DispatchQueue.main.asyncAfter(deadline: .now() ){
                self.tableView.reloadData()
                print(self.maxTemperatues)

            }
          
        }else
        {
            cityZipCodes.remove(at: cityZipCodes.count-1 )
            cityNames.remove(at: cityNames.count-1)
            let alertController = UIAlertController(title: "Oops, Something's wrong!", message: "The entered ZipCode doesn't exist.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .default, handler: {
                (action:UIAlertAction!)->Void in
            })
            alertController.addAction(cancelAction)
            self.present(alertController,animated: true,completion: nil)
        }
      

    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cityZipCodes.count;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureCell", for: indexPath)

        cell.textLabel?.text = cityNames[indexPath.row] + "("+cityZipCodes[indexPath.row].description+")"
        cell.detailTextLabel?.text = maxTemperatues[indexPath.row].description + "°F"
        cell.backgroundColor = UIColorFromTemperature(temperature: maxTemperatues[indexPath.row])
        cell.imageView?.image = temperatueImages[indexPath.row]
        return cell
    }
    


    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            cityZipCodes.remove(at: indexPath.row)
            maxTemperatues.remove(at: indexPath.row)
            cityNames.remove(at: indexPath.row)
            temperatueImages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

 

}
