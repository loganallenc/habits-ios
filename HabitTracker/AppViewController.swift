//
//  AppViewController.swift
//  Tailor
//
//  Created by Logan Allen on 2/22/16.
//  Copyright © 2016 Logan Allen. All rights reserved.
//


protocol AppViewController {

    var appCoordinator : AppCoordinator? { get set}

    var model : ViewModel? { get set}

    // use bond
    func bindModel() -> Bool
    
}