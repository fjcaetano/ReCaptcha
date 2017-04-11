//
//  ViewController.swift
//  ReCaptcha
//
//  Created by fjcaetano on 03/22/2017.
//  Copyright (c) 2017 fjcaetano. All rights reserved.
//

import UIKit
import ReCaptcha
import Result


class ViewController: UIViewController {
    fileprivate static let webViewTag = 123
    
    fileprivate let recaptcha = try! ReCaptcha()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recaptcha.presenterView = view
        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = ViewController.webViewTag
        }
    }
    
    
    @IBAction func didPressButton(button: UIButton) {
        spinner.startAnimating()
        button.isEnabled = false
        
        recaptcha.validate { [weak self] result in
            self?.spinner.stopAnimating()
            
            self?.label.text = try? result.dematerialize()
            self?.view.viewWithTag(ViewController.webViewTag)?.removeFromSuperview()
        }
    }
}

