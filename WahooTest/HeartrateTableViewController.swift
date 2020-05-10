//
//  HeartrateTableViewController.swift
//  WahooTest
//
//  Created by hiroki on 2020/05/10.
//  Copyright © 2020 hiroki. All rights reserved.
//

import UIKit

class HeartrateTableViewController: UITableViewController, WFSensorConnectionDelegate {

    var device: WFDeviceInformation?
    
    let connector = WFHardwareConnector.shared()
    var connection: WFHeartrateConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let params = device?.connectionParams(for: WF_SENSORTYPE_HEARTRATE) {
            connection = connector?.requestSensorConnection(params) as? WFHeartrateConnection
            connection?.delegate = self
        }
    }
    
    var updateTimer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if connection == nil {
            let alert = UIAlertController(title: "Error", message: "Connection Failed", preferredStyle: .alert)
            alert.addAction(.init(title: "Dismiss", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.reload()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
    }
    
    func connection(_ connectionInfo: WFSensorConnection!, rejectedByDeviceNamed deviceName: String!, appAlreadyConnected appName: String!) {
        let alert = UIAlertController(title: "Error", message: "Connection Rejected", preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func connection(_ connectionInfo: WFSensorConnection!, stateChanged connState: WFSensorConnectionStatus_t) {
        reload()
    }
    
    func connectionDidTimeout(_ connectionInfo: WFSensorConnection!) {
        let alert = UIAlertController(title: "Error", message: "Connection Timeout", preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    var heartrateData: WFHeartrateData?
    
    func reload() {
        heartrateData = connection?.getHeartrateData()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 6][section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 80 }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let heartrate = heartrateData

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "large", for: indexPath)
            cell.textLabel?.text = heartrate != nil ? "\(heartrate!.computedHeartrate)" : nil
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath)

        if indexPath.row == 0 {
            cell.textLabel?.text = "accumBeatCount"
            cell.detailTextLabel?.text = heartrate != nil ? "\(heartrate!.accumBeatCount)" : nil
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "beatTime"
            cell.detailTextLabel?.text = heartrate != nil ? "\(heartrate!.beatTime)" : nil
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "computedHeartrate"
            cell.detailTextLabel?.text = heartrate != nil ? "\(heartrate!.computedHeartrate)" : nil
        } else if indexPath.row == 3 {
            cell.textLabel?.text = "isDataStale"
            cell.detailTextLabel?.text = heartrate != nil ? "\(heartrate!.isDataStale)" : nil
        } else if indexPath.row == 4 {
            cell.textLabel?.text = "timestamp"
            cell.detailTextLabel?.text = heartrate != nil ? "\(heartrate!.timestamp)" : nil
        } else if indexPath.row == 5 {
            cell.textLabel?.text = "timestampOverflow"
            cell.detailTextLabel?.text = heartrate != nil ? "\(heartrate!.timestampOverflow)" : nil
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
