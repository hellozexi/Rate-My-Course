//
//  MyCoursesViewController.swift
//  CSE438 Final Project
//
//  Created by Mike Liu on 7/29/20.
//  Copyright © 2020 Michael Zhao. All rights reserved.
//



import Foundation
import UIKit
import FirebaseDatabase

class MyCourseTableViewCell: UITableViewCell{
    var myCourse:ResultCourse!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    func update(){
        nameLabel.text=myCourse.id+" "+myCourse.name
        unitLabel.text="Credit: "+String(myCourse.credits)
        descriptionLabel.text="Description: "+myCourse.description
    }
}
class MyCoursesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var resultTable: UITableView!
    let userdefaults = UserDefaults.standard
    var departmentID:String?
    var results: [ResultCourse] = []
    var selectedCourseID:String=""
    var selectedCourseName:String=""
    var selectedCourseCredit:String=""
    var selectedCourseDescription:String=""
    var username = "Sproull"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //resultTable.register(UITableViewCell.self, forCellReuseIdentifier: "classCell")
        resultTable.dataSource = self
        resultTable.delegate=self
        
        getCourses()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditVC" {
            let VC = segue.destination as? CourseEditController
            VC?.courseId = selectedCourseID
        }
//        if segue.identifier == "toEditVC" {
//            let VC = segue.destination as? UITabBarController
//            let barViews = VC?.viewControllers
//            let infoVC = barViews![0] as! CourseInfoViewController
//            let statsVC = barViews! [1] as! StatsViewController
//            //declare a course ID variable in CourseDetailViewController, and pass the selectedCourseID to it, and that will be the ID for the selected Course
//            statsVC.courseId = selectedCourseID
//            statsVC.departmentId = departmentID!
//            infoVC.courseId = selectedCourseID
//            infoVC.name = selectedCourseName
//            infoVC.credits = selectedCourseCredit
//            infoVC.courseDes = selectedCourseDescription
////            print(selectedCourseID)
////            print(selectedCourseName)
////            print(selectedCourseCredit)
////            print(selectedCourseDescription)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourseID=results[indexPath.row].id
        selectedCourseName = results[indexPath.row].name
        selectedCourseCredit = String(results[indexPath.row].credits)
        selectedCourseDescription = results[indexPath.row].description
        
        self.performSegue(withIdentifier: "toEditVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultTable.dequeueReusableCell(withIdentifier: "myCourseCell", for: indexPath) as! MyCourseTableViewCell
        cell.myCourse=results[indexPath.row]
        cell.update()
        return cell
    }
    
    func getCourses(){
        if let depID=departmentID{
            let ref = Database.database().reference().child("courses").child(depID)
            results=[]
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if(value==nil){
                    return
                }
                for course in value!{
                    let id = course.key as! String
                    let dic = course.value as! NSDictionary
                    let name = dic["name"] as! String
                    let credits = dic["unit"] as! Int
                    let description = dic["description"] as! String
                    if(dic["instructor"] == nil) {
                        continue
                    } 
                    let instructor = dic["instructor"] as! String
                    if(instructor == self.username) {
                        let course = ResultCourse(id: id, name: name, credits: credits, description: description, instructor: instructor)
                        self.results.append(course)
                    }
                    
                }
                self.results.sort(by: { $0.id < $1.id })
                self.resultTable.reloadData()
            
              // ...
              }) { (error) in
                
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
}
