//
//  ViewController.swift
//  maps2
//
//  Created by Zach Jones on 7/10/16.
//  Copyright © 2016 chris thompson. All rights reserved.
//

import UIKit
import Mapbox



class ViewController: UIViewController, UISearchBarDelegate {
    
    var locManager = CLLocationManager()
    
    var userLocationView = false

    var bookMarkImage = String()
    
    
    
 
    @IBOutlet weak var search: UISearchBar!
    var searchController: UISearchController!
    
    var searchIcons = ["Landscape Filled-50.png","Creek Filled-50 (1).png","Pin Filled-50.png"]
    var iconIndex = 0


    @IBOutlet var findUserLocationOutlet: UIButton!
    @IBOutlet var addIconOutlet: UIButton!
    var locationNames = [String]()
    
    
    var preferredFont: UIFont!
    
    var preferredTextColor: UIColor!
    

    
    
    
    
    @IBAction func seeUserLocation(sender: AnyObject) {
        
        if userLocationView == false {
        
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
            
            let latitude = locManager.location!.coordinate.latitude
            let longitude = locManager.location!.coordinate.longitude
            
            maps.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude,
                longitude: longitude),
                                     zoomLevel: 13, animated: true)
            
            userLocationView = true
            
            }
        }
        
            else {
            
            
                    maps.setCenterCoordinate(CLLocationCoordinate2D(latitude: 42.937992,
                        longitude: -85.735279),
                                     zoomLevel: 13, animated: true)
            
            
                    userLocationView = false

            
            
        
        }

        
        
    }

    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always try to show a callout when an annotation is tapped.
        return true
    }
    

    
    
    
    //Funcion to read stored JSON data
    
    
    func readJSONObject(object: [String: AnyObject]) {
        guard let title = object["dataTitle"] as? String,
            let version = object["swiftVersion"] as? Float,
            let locations = object["locations"] as? [[String: AnyObject]] else { return }
        _ = "Swift \(version) " + title
        
        
        for location in locations {
            guard let name = location["name"] as? String,
             let subTitle = location["subTitle"] as? String,


            let latitude = location["latitude"] as? CLLocationDegrees,
            let longitude = location["longitude"] as? CLLocationDegrees else { break }

            locationNames.append((location["name"] as? String)!)
            
            
            let point = MGLPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            point.title = name
            point.subtitle = subTitle

            
            maps.addAnnotation(point)
                





        }
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists

        let reuseIdentifier = reuseIdentifierForAnnotation(annotation)
        // try to reuse an existing annotation image, if it exists
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(reuseIdentifier)

        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
            

            
            var image = imageForAnnotation(annotation)
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)

            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
        }
        
        return annotationImage
    }
    
    func reuseIdentifierForAnnotation(annotation: MGLAnnotation) -> String {
        var reuseIdentifier = "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
        if let title = annotation.title where title != nil {
            reuseIdentifier += title!
        }
        if let subtitle = annotation.subtitle where subtitle != nil {
            reuseIdentifier += subtitle!
        }
        return reuseIdentifier
    }
    
    // lookup the image to load by switching on the annotation's title string
    func imageForAnnotation(annotation: MGLAnnotation) -> UIImage {
        var imageName = ""
        if let title = annotation.title where title != nil {
            switch title! {
            case "blah":
                imageName = "blahImage"
            default:
                
                let imageIcons = ["pin-poi-hunting@2x", "pin-custom-hunting@2x", "pin-poi-fishing@2x", "pin-custom-fishing@2x"]
                let randomIndex = Int(arc4random_uniform(UInt32(imageIcons.count)))
                imageName = imageIcons[randomIndex]
                
                print(imageName)
            }
        }
        // ... etc.
        return UIImage(named: imageName)!
    }
    
    

    
    
    @IBOutlet var maps: MGLMapView!
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        
        
            if iconIndex < 2 {
                
                iconIndex = iconIndex + 1
            } else {
                
                iconIndex = 0
            }
            
            let image = UIImage(named: searchIcons[iconIndex])
            search.setImage(image, forSearchBarIcon: UISearchBarIcon.Bookmark, state: .Normal)
        
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        
        
        

    }

    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let searchImage = UIImage(named: "icon-search@2x.png")
        let bookMarkImage = UIImage(named: "Landscape filled-50.png")
        search.setImage(searchImage, forSearchBarIcon: UISearchBarIcon.Search, state: .Normal)
        search.setImage(bookMarkImage, forSearchBarIcon: UISearchBarIcon.Bookmark, state: .Normal)
        
        self.bookMarkImage = "mountain"
        
        search.delegate = self;


        locManager.requestWhenInUseAuthorization()
        
        
        let url = NSBundle.mainBundle().URLForResource("data", withExtension: "json")
        let data = NSData(contentsOfURL: url!)
        
        do {


            let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(dictionary)
            }
        } catch {
            // Handle Error
        }
        

        self.findUserLocationOutlet.layer.cornerRadius = self.findUserLocationOutlet.frame.size.width / 2;
        self.findUserLocationOutlet.clipsToBounds = true
    
    
        self.addIconOutlet.layer.cornerRadius = self.addIconOutlet.frame.size.width / 2;
        self.addIconOutlet.clipsToBounds = true
        


        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

