//
//  MyPDFView.swift
//  PDFMarginTextView
//
//  Created by JC Nolan on 3/2/21.
//

import Cocoa
import PDFKit

struct Comment {
    
    var text:   String? = nil
    var selection: PDFSelection? = nil
    var color:  NSColor? = nil
}

class PDFMarginTextView: PDFView {
    
    var comments: [Comment] = []
    let highlighterColor:NSColor = NSColor(red:0.95, green:0.61, blue:0.73, alpha:0.25) // Highlighter Pink
    var margin: CGSize? = nil
    
    override func draw(_ page: PDFPage, to context: CGContext) {
        
        // Draw PDF Page First
        
        super.draw(page, to: context)
        
        // Now, apply highlighting and margin comments for page
            
        let textContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.current = textContext
        
        // Set up values related to font/paragraph style for margin text
        
        let fontSize:    CGFloat = 12.0     // Margin text font size
        let lineSpacing: CGFloat = 0.0      // Extra space between lines
        let lineHeight:  CGFloat = fontSize // Line height
        let marginWidth: CGFloat = 10.0     // Hard-coded for demo, desired margin for text
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment          = .left
        paragraphStyle.lineSpacing        = lineSpacing
        paragraphStyle.lineHeightMultiple = lineSpacing
        paragraphStyle.maximumLineHeight  = lineHeight
        paragraphStyle.minimumLineHeight  = lineHeight
        
        let commentFont  = "Verdana-Italic"
        let commentColor = NSColor.black
        
        let margintTextAttributes = [ NSAttributedString.Key.foregroundColor: commentColor,
                                      NSAttributedString.Key.backgroundColor: NSColor.clear,
                                      NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                      NSAttributedString.Key.font: NSFont(name: commentFont, size: fontSize) ]
        
        let isOddPage:Bool = (((page.pageRef?.pageNumber ?? 0) % 2) != 0) 
        
        // Loop through comments drawing highlight / margin text for each
        
        for comment in comments {
            
            if let selection = comment.selection,
               let commentColor = comment.color,
               let commentText = comment.text {
                
                var maxY: CGFloat = CGFloat.leastNormalMagnitude
                var minY: CGFloat = CGFloat.greatestFiniteMagnitude
                
                // Draw text highlights and determine actual height of selection.
                
                for line in selection.selectionsByLine() {
                    
                    let lineBox = line.bounds(for: page)
                    
                    if (lineBox.origin.y + lineBox.height) > maxY {
                        maxY = (lineBox.origin.y + lineBox.height)
                    }
                    
                    if lineBox.origin.y < minY {
                        minY = lineBox.origin.y
                    }
                    
                    context.setFillColor(commentColor.cgColor)
                    context.setStrokeColor(NSColor.clear.cgColor)
                    context.setLineWidth(1)
                    
                    context.addRect(lineBox)
                    context.setBlendMode(.multiply)
                    context.drawPath(using: .fillStroke)
                }
                
                // Draw comment text on page - first set up font
                
                let commentStr   = NSMutableAttributedString(string: commentText)

                commentStr.addAttributes(margintTextAttributes as [NSAttributedString.Key : Any],
                                         range: NSRange(location: 0, length: commentStr.length))
                
                let myLeftTextEdge:  CGFloat = 80.0 + (margin != nil ? margin!.width * 72.0 : 0.0) // Hard-coded for demo, xpos on page where text starts (ie, left margin)
                let selectionHeight: CGFloat = CGFloat(maxY - minY)
                let highlightBox = selection.bounds(for: page)
                
                let commentBoxWidth: CGFloat = myLeftTextEdge - (marginWidth * 2)
                let pageBox: CGRect = page.bounds(for: displayBox)
                let xPos = isOddPage ? Int(pageBox.width - (marginWidth + commentBoxWidth)) : Int(pageBox.origin.x + marginWidth)
                
                let commentBoxHeight = TextCellHelper.calculateCellHeight(for: commentStr, with: commentBoxWidth, minHeight: selectionHeight)
                let commentBoxYPos   = highlightBox.origin.y + highlightBox.height - commentBoxHeight
                
                let commentMarginBox: CGRect = CGRect(x: CGFloat(xPos), y: commentBoxYPos,
                                                      width: commentBoxWidth, height: commentBoxHeight)
                
                commentStr.draw(in: commentMarginBox)
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        
        Swift.print("\n\nMOUSE UP ON PDF VIEW: \( event )\n")
        
        if let currentSelection = self.currentSelection,
           let currentSelectionText = currentSelection.string
           {
            // Let the Controller know that the selection changed
            
            let notificationKey = selectCompleteNotification
            Swift.print("Sending \(notificationKey) notification")
            
            var userInfo:[AnyHashable:Any]   = [:]
            userInfo[currentSelectedTextKey]    = currentSelectionText as String
            userInfo[currentPDFSelectionKey]    = currentSelection as PDFSelection
            
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: notificationKey),
                object: self,
                userInfo: userInfo)
        }
        
        // Now pass control back to app
        
        super.mouseUp(with: event)
    }
    
    // ================
    
    func saveComment(commentText: String, selection: PDFSelection) {
        
        let comment = Comment(text: commentText, selection: selection, color: highlighterColor)
        comments.append(comment)
        
        self.clearSelection()
        self.needsDisplay = true // Forces redraw of view
    }
    
    func resetComments()
    {
        comments = []
        self.needsDisplay = true
    }
}
