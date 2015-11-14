//
//  ViewController.swift
//  DesireKeyboard
//
//  Created by Tomoya Hirano on 2015/11/12.
//  Copyright © 2015年 Tomoya Hirano. All rights reserved.
//

import UIKit
import GameKit

class ViewController: GCEventViewController {


    @IBOutlet weak var keyboardView: DesireKeyboardView!
    @IBOutlet weak var textField: UITextField!
//    var controller:GCController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardView.targetInput = textField
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupController) name:GCControllerDidConnectNotification object:nil];
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupController:", name: GCControllerDidConnectNotification, object: nil)
        

    }
    
    func setupController(notification:NSNotification){
        if let controller = GCController.controllers().first?.microGamepad?.controller {
            controller.motion?.valueChangedHandler = {(motion) in
                print(motion.attitude)
            }
//            controller.microGamepad?.dpad.xAxis.valueChangedHandler = { (_) in
//                print(controller.microGamepad?.dpad.xAxis.value)
//            }
//            controller.microGamepad?.dpad.yAxis.valueChangedHandler = { (_) in
//                
//            }
//            controller.motion?.valueChangedHandler = {(motion:GCMotion)in
//                print(motion.gravity.x)
//            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

