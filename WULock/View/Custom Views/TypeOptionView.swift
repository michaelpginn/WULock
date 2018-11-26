//
//  TypeOptionView.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit


class TypeOptionView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    public var title:String = ""{
        didSet{
            titleLabel.text = title
        }
    }
    
    public var iconImage:UIImage? = nil{
        didSet{
            iconImageView.image = iconImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //partially adapted from https://medium.com/@brianclouser/swift-3-creating-a-custom-view-from-a-xib-ecdfe5b3a960
    private func commonInit(){
        Bundle.main.loadNibNamed("TypeOptionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.layer.cornerRadius = 8.0
        contentView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        contentView.layer.borderWidth = 2.0
    }

    public func setSelected(_ selected: Bool){
        if selected{
            contentView.layer.borderColor = UIColor(red: 165/255.0, green: 20/255.0, blue: 22/255.0 , alpha: 1.0).cgColor
            contentView.alpha = 1.0
        }else{
            contentView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
            contentView.alpha = 0.5
        }
    }
}
