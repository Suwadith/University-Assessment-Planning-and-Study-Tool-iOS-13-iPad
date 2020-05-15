//
//  DetailViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/12/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {


    @IBOutlet weak var assessmentNameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = assessmentNameLabel {
                label.text = detail.assessmentName
            }
        }
    }

    var detailItem: Assessment? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

