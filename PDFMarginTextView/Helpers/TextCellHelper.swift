//
//  TextHelper.swift
//  PDFMarginTextView
//
//  Created by JC Nolan on 3/2/21.
//

import Cocoa

class TextCellHelper {
   
    static func calculateCellHeight(for text: Any, with width: CGFloat, minHeight: CGFloat = 20.0) -> CGFloat { 
        var height: CGFloat = minHeight
        if let textValue = TextCellHelper.convertToNSMutableAttributedString(text) {
            let tempTextCell = NSTextFieldCell()
            tempTextCell.wraps = true
            tempTextCell.attributedStringValue = textValue
            let textHeight: CGFloat = tempTextCell.cellSize(forBounds: NSMakeRect(0, 0, width, CGFloat.greatestFiniteMagnitude)).height
            height = CGFloat.maximum(minHeight, textHeight)
        }
        return height
    }
    
    static func calculateCellWidth(for text: Any, with height: CGFloat, minWidth: CGFloat = 50.0) -> CGFloat {
        var width: CGFloat = minWidth
        if let textValue = TextCellHelper.convertToNSMutableAttributedString(text) {
            let tempTextCell = NSTextFieldCell()
            tempTextCell.attributedStringValue = textValue
            let textWidth: CGFloat = tempTextCell.cellSize(forBounds: NSMakeRect(0, 0, CGFloat.greatestFiniteMagnitude, height)).width
            width = CGFloat.maximum(minWidth, textWidth)
        }
        return width
    }
    
    static func convertToNSMutableAttributedString(_ text: Any) -> NSMutableAttributedString? {
        var convertedText: NSMutableAttributedString?
        switch text {
        case let stringText as String: convertedText = NSMutableAttributedString(string: stringText)
        case let attributedStringText as NSAttributedString: convertedText = NSMutableAttributedString(attributedString: attributedStringText)
        case let mutableAttributedStringText as NSMutableAttributedString: convertedText = mutableAttributedStringText
        default: break // Could not convert text
        }
        return convertedText
    }
    
}
