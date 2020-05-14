//
//  DetailViewController.swift
//  UniversityAssessmentPlanningTool
//
//  Created by Suwadith on 5/12/20.
//  Copyright © 2020 Suwadith. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.asssessmentModuleName
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: Assessment? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

