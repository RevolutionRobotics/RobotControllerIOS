//
//  UIImage+Size.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func rescaled(to scale: CGFloat) -> UIImage {
        let scaledSize = CGSize(
            width: size.width * scale,
            height: size.height * scale)
        return resized(to: scaledSize)
    }

    func draw(image: UIImage, inRect rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

    func rescaleContent(to scale: CGFloat) -> UIImage? {
        let rescaledContent = rescaled(to: scale)
        let centeredPoint = CGPoint(
            x: (size.width - rescaledContent.size.width) / 2,
            y: (size.height - rescaledContent.size.height) / 2)
        let contentRect = CGRect(
            x: centeredPoint.x,
            y: centeredPoint.y,
            width: rescaledContent.size.width,
            height: rescaledContent.size.height)

        return draw(image: rescaledContent, inRect: contentRect)
    }
}
