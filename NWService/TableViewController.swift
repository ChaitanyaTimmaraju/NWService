//
//  TableViewController.swift
//  NWService
//
//  Created by TIMMARAJU SAI V on 4/14/17.
//  Copyright © 2017 OSU. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController,XMLParserDelegate {

    
    var cityZipCodes = ["74075","25414","20910","74008"];
    var maxTemperatues = [Int]();
    var currentDate = ""
    var check = false
  
    
    @IBAction func addNewZip(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Enter Zipcode", message: "", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: {
            alert->Void in
             let firstTextField = alertController.textFields![0] as UITextField
            
            if(!self.cityZipCodes.contains(firstTextField.text!))
            {
                
                print("\(firstTextField.text)")
                self.cityZipCodes.append(firstTextField.text!)
                self.retriveDataFromZip(firstTextField.text!)
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
        let baseURL = "https://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?whichClient=NDFDgenByDayMultiZipCode&lat=&lon=&listLatLon=&lat1=&lon1=&lat2=&lon2=&resolutionSub=&endPoint1Lat=&endPoint1Lon=&endPoint2Lat=&endPoint2Lon=&centerPointLat=&centerPointLon=&distanceLat=&distanceLon=&resolutionSquare=&zipCodeList=\(zip)&citiesLevel=&format=24+hourly&startDate=\(currentDate)&numDays=2&Unit=e&Submit=Submit";
        
        
        let urlToSend:URL = URL(string: baseURL)!
        let parser = XMLParser(contentsOf: urlToSend)
        parser?.delegate = self
        parser?.parse();
        
     
        
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
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "temperature"
        {
            self.check = false;
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
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if cityZipCodes.count == maxTemperatues.count
        {
            self.tableView.reloadData()
        }else
        {
            cityZipCodes.remove(at: cityZipCodes.count-1 )
            
            let alertController = UIAlertController(title: "Oops,Something's wrong!", message: "The entered ZipCode doesn't exist.", preferredStyle: .alert)
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

        cell.textLabel?.text = cityZipCodes[indexPath.row].description
        cell.detailTextLabel?.text = maxTemperatues[indexPath.row].description + "F"
        
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
