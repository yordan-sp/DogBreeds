//
//  Image+Size.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 9.05.22.
//

import UIKit

extension UIImage {
    func resizedImage(size: CGSize = CGSize(width: 100, height: 80)) -> UIImage {
        let originalSize = self.size

        let widthRatio = size.width / originalSize.width
        let heightRatio = size.height / originalSize.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: originalSize.width * heightRatio, height: originalSize.height * heightRatio)
        } else {
            newSize = CGSize(width: originalSize.width * widthRatio, height: originalSize.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
