//
//  MuralTVC.swift
//  Brighton Murals
//
//  Created by Kevon Rahimi on 05/12/2022.
//

import UIKit
import MapKit
import CoreLocation

class MuralTVC: UITableViewController,MKMapViewDelegate, CLLocationManagerDelegate{
    
    // MARK: - Variables & Outlets
    // For segue
    var rowNumber: Int?
    
    // For jsonData
    var mural:Murals? = nil
    var image:Image? = nil
    var thumbnails = [String:UIImage]()
    
    // For map
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    var distance:Double?
    var userLocation:CLLocation?

    // Favourites
    var favourite = [Favourites]()
    
    // Outlets
    @IBOutlet var myTable: UITableView!
    @IBOutlet weak var myMap: MKMapView!
    
    // Persistant container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Extracting JsonData
        if let url = URL(string:"https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm/data2.php?class=newbrighton_murals") {
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else {
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let dataList = try decoder.decode(Murals.self, from: jsonData)
                    self.mural = dataList
                    
//                    DispatchQueue.main.async {
//                        self.updateTheTable()
//                    }
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
        }
        //MARK: - Image data for thumbnails
        if let url = URL(string:"https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm/data2.php?class=newbrighton_murals") {
            let session = URLSession.shared
            session.dataTask(with: url) { [self] (data, response, err) in
                do {
                    for i in 0..<(mural?.newbrighton_murals.count ?? 0)  {
                        let url = URL(string: (mural?.newbrighton_murals[i].thumbnail)!)!
                        if let data = try? Data(contentsOf: url) {
                            thumbnails[(mural?.newbrighton_murals[i].title)!] =  UIImage( data: data )!
                        }}
                    DispatchQueue.main.async {
                        self.updateTheTable()
                    }
                }
                }.resume()
            }
        
        //MARK: - User Location
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        myMap.showsUserLocation = true
        
        //MARK: - Map
        updateTableOrder()
        }
    
//MARK: - Table Column and Row setup
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mural?.newbrighton_murals.count ?? 0
    }
    
    func updateTheTable() {
        myTable.reloadData()
    }
    
// MARK: - Putting Json Data into Cells of table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomTableViewCell = CustomTableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "theCell")
        cell.link = self
        
        cell.accessoryView?.tintColor = mural?.newbrighton_murals[indexPath.row].hasFavourited ?? false ? UIColor.yellow : .lightGray
        //Title and artist information
        cell.textLabel?.text = mural?.newbrighton_murals[indexPath.row].title ?? "no title"
        cell.detailTextLabel?.text = mural?.newbrighton_murals[indexPath.row].artist ?? "no artist"
        
        //Thumbnails
        cell.imageView?.image = thumbnails[(mural?.newbrighton_murals[indexPath.row].title)!]
        
        
        //MARK: - Add mural titles and pin to map
        addMuralToMap(latitude: (mural?.newbrighton_murals[indexPath.row].lat)!, longitude: (mural?.newbrighton_murals[indexPath.row].lon)!, name: (mural?.newbrighton_murals[indexPath.row].title)!)
        
        return cell
    }
    
    
    
    
    
// MARK: - User location functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0]
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        userLocation = CLLocation(latitude: latitude, longitude: longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
        if firstRun {
            firstRun = false
            
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.myMap.setRegion(region, animated: true)
            
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startUserTracking), userInfo: nil, repeats: false)
        }
        if startTrackingTheUser == true {
            myMap.setCenter(location, animated: true)
        }
        updateTableOrder()
    }
    
    @objc func startUserTracking() {
        startTrackingTheUser = true
    }
    
//MARK: - Add to Map function
    func addMuralToMap(latitude: String, longitude: String, name: String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
        annotation.title = name
        myMap.addAnnotation(annotation)
    }
    
    
//MARK: - Working out distance and rearranging cells
    func findOutDistance(longitude: String, latitude: String, index: Int){
        let lon = Double(longitude)
        let lat = Double(latitude)
        let destinationCoords: CLLocation =  CLLocation(latitude: lat!, longitude: lon!)
        let distance: CLLocationDistance = destinationCoords.distance(from: userLocation!)
        mural?.newbrighton_murals[index].distance = distance
    }
    func updateTableOrder() {
        for i in 0..<(mural?.newbrighton_murals.count ?? 0)  {
            findOutDistance(longitude: (mural?.newbrighton_murals[i].lon)!, latitude: (mural?.newbrighton_murals[i].lat)!, index: i)
            mural?.newbrighton_murals.sort(by: { $0.distance ?? 0 < $1.distance ?? 0})
        }
        self.updateTheTable()
    }
    
// MARK: - Segue
    // Performing Segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowNumber = indexPath.row
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    // Segue Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? ViewController else { return }
        destinationVC.muralTitle =  mural?.newbrighton_murals[rowNumber!].title
        destinationVC.muralArtist = mural?.newbrighton_murals[rowNumber!].artist
        destinationVC.muralInfo = mural?.newbrighton_murals[rowNumber!].info
        if (mural?.newbrighton_murals[rowNumber!].enabled == "1"){
            destinationVC.muralImage = mural?.newbrighton_murals[rowNumber!].images![0].filename
        }
    }
//MARK: - Favourites
    func linkMethod(cell: UITableViewCell){
        tableView.indexPath(for: cell)
        let indexPathTapped = tableView.indexPath(for: cell)
    // *test* print(indexPathTapped!)
        let hasFavourited = mural?.newbrighton_murals[indexPathTapped!.row].hasFavourited
        mural?.newbrighton_murals[indexPathTapped!.row].hasFavourited = !(hasFavourited ?? false)
    // *test*  print(mural?.newbrighton_murals[indexPathTapped!.row].hasFavourited as Any)
        
       tableView.reloadRows(at: [indexPathTapped!], with: .fade)

    }
//MARK: - Persistant data attempt
    func fetchMurals(){
        do{
            self.favourite = try context.fetch(Favourites.fetchRequest())
            DispatchQueue.main.async{
                self.updateTheTable()
            }
        }
        catch{
            
        }
    }
}
