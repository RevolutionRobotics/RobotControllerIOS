//
//  NSAttributedString+HTML.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 07. 08..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    private enum Constants {
        static let fontName = "Barlow"
        //swiftlint:disable line_length
        static let formatString =
        """
        <head>
        <link href="https://fonts.googleapis.com/css?family=Barlow:400,400i,500,500i,700,700i&display=swap" rel="stylesheet">
        </head>
        <span style=\"font-family:'\(Constants.fontName)'; font-size:%@; color:white;\">%@</span>
        """
        //swiftlint:enable line_length
    }

    static func attributedString(from html: String, fontSize: CGFloat) -> NSAttributedString {
        let modifiedHtml = String(format: Constants.formatString, "\(fontSize)", html)
        if let attributedString = try? NSAttributedString(
            data: modifiedHtml.data(using: .utf8, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) {
            return attributedString
        } else {
            return NSAttributedString(string: html)
        }
    }
}
