//
//  DiscoveryTableViewController.swift
//  WahooTest
//
//  Created by hiroki on 2020/05/10.
//  Copyright © 2020 hiroki. All rights reserved.
//

import UIKit

class DiscoveryTableViewController: UITableViewController, WFDiscoveryManagerDelegate {

    let discoveryManager = WFDiscoveryManager()
    
    var resumeDiscoveringNotification: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discoveryManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(startDiscovery), name: UIApplication.didBecomeActiveNotification, object: nil)
        startDiscovery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        cancelDiscovery()
    }
    
    @objc func startDiscovery() {
        discoveryManager.discoverSensorTypes(nil, on: WF_NETWORKTYPE_BTLE)
    }
    
    @objc func cancelDiscovery() {
        discoveryManager.cancelDiscovery()
    }
    
    func discoveryManager(_ discoveryManager: WFDiscoveryManager!, didDiscoverDevice deviceInformation: WFDeviceInformation!) {
        reload()
    }
    
    func discoveryManager(_ discoveryManager: WFDiscoveryManager!, didLooseDevice deviceInformation: WFDeviceInformation!) {
        reload()
    }

    // MARK: - Table view data source
    
    var discoveredDevices = [WFDeviceInformation]()
    
    func reload() {
        discoveredDevices = []
        for device in discoveryManager.discoveredDevices() ?? [] {
            guard let info = device as? WFDeviceInformation else { continue }
            if discoveredDevices.contains(where: { $0.deviceIdentifier == info.deviceIdentifier }) { continue }
            discoveredDevices.append(info)
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { discoveredDevices.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let device = discoveredDevices[indexPath.row]
        cell.textLabel?.text = device.rawName
        cell.detailTextLabel?.text = device.deviceIdentifier

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "detail", sender: discoveredDevices[indexPath.row])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let detail = segue.destination as? DeviceDetailTableViewController {
            detail.deviceInfo = sender as? WFDeviceInformation
        }
    }

}
