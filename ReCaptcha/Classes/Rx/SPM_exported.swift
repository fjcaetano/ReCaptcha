//
//  SPM_exported.swift
//  
//
//  Created by Jakub Mazur on 15/07/2021.
//

/*

Since Swift Package Manager have directory structure and folders cannot override
this module import is needed to use internal dependency in ReCaptcha+Rx.swift file.

This file should NOT be included in Cocoapods and Carthage build

*/

@_exported import ReCaptcha
