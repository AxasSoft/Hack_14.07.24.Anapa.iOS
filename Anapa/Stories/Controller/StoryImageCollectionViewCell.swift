//
//  StoryImageCollectionViewCell.swift
//  NotAlone
//
//  Created by Сергей Майбродский on 29.06.2022.
//

import UIKit



class StoryImageCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var context = CIContext(options: nil)

    func blurEffect(image: UIImageView) {

        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: image.image!)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)

        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")

        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        image.image = processedImage
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
