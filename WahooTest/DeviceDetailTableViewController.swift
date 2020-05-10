//
//  DeviceDetailTableViewController.swift
//  WahooTest
//
//  Created by hiroki on 2020/05/10.
//  Copyright © 2020 hiroki. All rights reserved.
//

import UIKit

class DeviceDetailTableViewController: UITableViewController {
    
    var deviceInfo: WFDeviceInformation?
    
    var attributes = [(title: String, value: String)]()
    var sensors = [(name: String, type: WFSensorType_t)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }
    
    var updateTimer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (_) in
            self.reload()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
    }
    
    func reload() {
        defer {
            tableView.reloadData()
        }
        guard let device = deviceInfo else {
            attributes = []
            return
        }
        
        title = device.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        attributes = [
            ("Name", device.name ?? "NULL"),
            ("Raw Name", device.rawName ?? "NULL"),
            ("Connected", "\(device.connected)"),
            ("Battery Level", device.isBatteryLevelSupported() ? "\(device.batteryLevel)" : "Unsupported"),
            ("Device Identifier", device.deviceIdentifier ?? "NULL"),
            ("Firmware Version", device.firmwareVersion ?? "NULL"),
            ("Hardware Version", device.hardwareVersion ?? "NULL"),
            ("Last Update", device.lastUpdate != nil ? dateFormatter.string(from: device.lastUpdate) : "None"),
            ("Manufacture", device.manufacturer ?? "NULL"),
            ("Product Key", device.productKey ?? "NULL"),
            ("Serial Number", device.serialNumber ?? "NULL"),
            ("Signal Strength", "\(device.signalStrength)"),
        ]
        
        let types: [UInt: String] = [
            0: "NONE",
            0x00000001: "BIKE POWER",
            0x00000002: "BIKE SPEED",
            0x00000004: "BIKE CADENCE",
            0x00000008: "BIKE SPEED CADENCE",
            0x00000010: "FOOTPOD",
            0x00000020: "HEARTRATE",
            0x00000040: "WEIGHT SCALE",
            0x00000080: "ANT FS",
            0x00000100: "LOCATION",
            0x00000200: "CALORIMETER",
            0x00000400: "GEO CACHE",
            0x00000800: "FITNESS EQUIPMENT",
            0x00001000: "MULTISPORT SPEED DISTANCE",
            0x00002000: "PROXIMITY",
            0x00004000: "HEALTH THERMOMETER",
            0x00008000: "BLOOD PRESSURE",
            0x00010000: "BTLE GLUCOSE",
            0x00020000: "GLUCOSE",
            0x00800000: "DISPLAY",
            0x08000000: "WAHOO RAW SENSOR",
            0x10000000: "WAHOO GYM CONNECT",
            0x80000000: "WAHOO ADVANCED FITNESS MACHINE",
            0x100000000: "WAHOO HEADWIND",
            0x200000000: "WAHOO KICKR BIKE",
        ]
        sensors = device.supportedSensorTypes.compactMap({ typeObj in
            let type = WFSensorType_t(typeObj as! UInt)
            return (types[type.rawValue] ?? "Unknown", type)
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [attributes.count, sensors.count][section]
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Attributes", "Sensors"][section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath)
            
            let info = attributes[indexPath.row]
            cell.textLabel?.text = info.title
            cell.detailTextLabel?.text = info.value

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sensor", for: indexPath)

            cell.textLabel?.text = sensors[indexPath.row].name
            
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 { return }
        let type = sensors[indexPath.row].type
        if type == WF_SENSORTYPE_HEARTRATE {
            performSegue(withIdentifier: "heartrate", sender: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Unsupported Sensor Type", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        (segue.destination as? HeartrateTableViewController)?.device = deviceInfo
    }

}
