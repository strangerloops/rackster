//
//  AppDelegate.swift
//  Rackster
//
//  Created by Michael Hassin on 4/28/15.
//  Copyright (c) 2015 strangerware. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if NSKeyedUnarchiver.unarchiveObjectWithFile(archivePath()) as? [CLLocation] == nil {
            archiveCoordinates()
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = MapViewController()
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        return true
    }

    func archivePath() -> String {
        return NSHomeDirectory().stringByAppendingPathComponent("Documents/coordinates.archive")
    }
    
    func archiveCoordinates() {
        let path = NSBundle.mainBundle().pathForResource("racks", ofType: "txt");
        let data = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
        let coordinates = (split(data!) { $0 == "\n" }
            .map { split($0) { delimiter in delimiter == "," } })
            .map { CLLocation(latitude: ($0.first! as NSString).doubleValue, longitude: ($0.last! as NSString).doubleValue) }
    
        NSKeyedArchiver.archiveRootObject(coordinates, toFile: archivePath())
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        tracking()
    }
    
    func tracking(){
        let url = NSURL(string: "https://shrouded-woodland-3380.herokuapp.com/plusone")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in }
    }
}

