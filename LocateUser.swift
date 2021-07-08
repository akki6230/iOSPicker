//
//  LocateUser.swift
//  Sample
//
//  Created by Ankit Kumar on 17/02/21.
//  Copyright © 2021 Ankit Kumar. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

private let getlocation: GetLocation = GetLocation.shared
class LoacteUser: NSObject{
    
    static let shared = LoacteUser()
    
    /**
     Get User location  with address.
     
     - Parameters:
     - ------

     - returns: closure with user location address, lat, long, error.
     */
    public func get(userLocation: @escaping (_ addressString: String?,_ lat: Double,_ lng: Double,_ error: Error?) -> Void){

        getlocation.isUserCoordinatesUpdated = false
        getlocation.showLoaction()
        getlocation.onLocationFind = {(addressString, lat, lng, err) in
            userLocation(addressString, lat, lng, err)
        }
    }
}


private class GetLocation: NSObject{
    
    static let shared = GetLocation()
    
    //MARK:- Public Vars
    var onLocationFind: ((_ addressString: String?,_ lat: Double,_ lng: Double,_ error: Error?)-> Void)?
    
    //MARK:- private Vars
    private var locationManger: CLLocationManager!
    var isUserCoordinatesUpdated = false
    
    //MARK: Public Methods
    public func showLoaction(){
        
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            print(status)
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManger.requestWhenInUseAuthorization()
                locationManger.startUpdatingLocation()
                break
            case .denied, .restricted:
                self.openSettings()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManger.startUpdatingLocation()
                break
            @unknown default:
                break
            }
        } else {
            TAUtility.showOkAlert(title: kConstAppName, message: "Please enable location services to detect location.")
        }
    }
}

extension GetLocation: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            //good to go!
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.startUpdatingLocation()
            
        }else if status == .notDetermined{
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.requestWhenInUseAuthorization()
            locationManger.startUpdatingLocation()
        } else if status == .denied{
            self.openSettings()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0, let userLocation = locations.first{
            locationManger.stopUpdatingLocation()
            
            // show welcome screen
            if !isUserCoordinatesUpdated{
                isUserCoordinatesUpdated = true
                
                // send location, get address
                getAddressFromLatLon(lat: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        TAUtility.showOkAlert(title: kConstAppName, message: error.localizedDescription)
        // send location
        onLocationFind?(nil, 0.0, 0.0, error)
        locationManger.stopUpdatingLocation()
    }
    
    
    //MARK:- Helpers
    private func getAddressFromLatLon(lat: Double, withLongitude lng: Double) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lng

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
                        print(pm.country as Any)
                        print(pm.locality as Any)
                        print(pm.subLocality as Any)
                        print(pm.thoroughfare as Any)
                        print(pm.postalCode as Any)
                        print(pm.subThoroughfare as Any)
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        //print()
                        
                        // send response
                        self.onLocationFind?(addressString, lat, lng, nil)
                  }
            })

        }
    
    private func openSettings(){
        var alertPayLoad = PopUpPayLoad(title: "App Permission Denied",
                                        message: "To re-enable, please go to Settings and turn on Location Service for this app.",
                                        images: nil,
                                        style: .center)
        
        let ok = PopUpButton(title: "Open Settings", style: .default) {
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
        alertPayLoad.addAction([ok])
        if let cc = UIWindow.currentController{
            alertPayLoad.show(cc)
        }
    }
}
