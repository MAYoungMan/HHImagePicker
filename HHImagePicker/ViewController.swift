//
//  ViewController.swift
//  HHImagePicker
//
//  Created by Sherlock on 11/02/2018.
//  Copyright © 2018 daHuiGe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var Sheet: HHPhotoActionSheet? = nil
    
    var lastSelectModels: [HHSelectPhotoModel]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Sheet = HHPhotoActionSheet.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 200), superView: self.view)
        Sheet?.maxSelectCount = 9
        Sheet?.maxPreviewCount = 25
        
        let previewButton:UIButton = UIButton(type:.system)
        previewButton.frame = CGRect(x:30, y:350, width:150, height:30)
        previewButton.setTitle("选择照片(预览)", for:.normal)
        previewButton.addTarget(self, action: #selector(ViewController.showPreview), for: .touchUpInside)
        self.view.addSubview(previewButton)
        
        let libraryButton:UIButton = UIButton(type:.system)
        libraryButton.frame = CGRect(x:UIScreen.main.bounds.size.width-180, y:350, width:150, height:30)
        libraryButton.setTitle("选择照片(相册)", for:.normal)
        libraryButton.addTarget(self, action: #selector(ViewController.showLibrary), for: .touchUpInside)
        self.view.addSubview(libraryButton)
        
    }
    
    @objc func showPreview() {
        Sheet?.showPreviewPhoto(withSender: self, last: lastSelectModels) { (selectPhotos, selectPhotoModels) in
            self.lastSelectModels = selectPhotoModels
        }
    }
    @objc func showLibrary() {
        Sheet?.showPhotoLibrary(withSender: self, last: lastSelectModels) { (selectPhotos, selectPhotoModels) in
            for image in selectPhotos {
                print(image)
            }
            self.lastSelectModels = selectPhotoModels
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

