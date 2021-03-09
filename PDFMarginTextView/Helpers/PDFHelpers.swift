//
//  PDF.swift
//
//  Created by Ben Bahrenburg on 1/1/17.
//  Copyright © 2017 bencoding.. All rights reserved.
//
//import UIKit
import Foundation
import PDFKit

open class PDFHelpers {
    
    class open func unlock(data: Data, password: String) -> CGPDFDocument? {
        
        if let pdf = CGPDFDocument(CGDataProvider(data: data as CFData)!) {
            guard pdf.isEncrypted == true else { return pdf }
            guard pdf.unlockWithPassword("") == false else { return pdf }
            if let cPasswordString = password.cString(using: String.Encoding.utf8) {
                if pdf.unlockWithPassword(cPasswordString) {
                    return pdf
                }
            }
        }
        return nil
    }
    
    class open func pdfToCGPDF(source:PDFDocument)->CGPDFDocument? {
        
        var retVal: CGPDFDocument? = nil
        
       // let pdfData:CFData = source.dataRepresentation()
        if let cfData = source.dataRepresentation() as CFData? {
     //   let cfData = pdfData! as? CFData
            let cgDataProvider = CGDataProvider(data: cfData)
            retVal = CGPDFDocument(cgDataProvider!)
        }
        
        return retVal
    }
    
    class open func cgpdfToPdf(source:CGPDFDocument)->PDFDocument? {
        
        var retVal: PDFDocument? = nil
    //    let pdfData = dataRepresentation(source)
        
        retVal = PDFDocument(data: source as! Data)
        
        return retVal
    }

    /*
    class open func removePassword(data: Data, existingPDFPassword: String) throws -> Data? {
        
        if let pdf = unlock(data: data, password: existingPDFPassword) {
            let data = NSMutableData()
            
            autoreleasepool {
                
                let pageCount = pdf.numberOfPages
                UIGraphicsBeginPDFContextToData(data, .zero, nil)
                
                for index in 1...pageCount {
                    let page = pdf.page(at: index)
                    let pageRect = page?.getBoxRect(CGPDFBox.mediaBox)
                    UIGraphicsBeginPDFPageWithInfo(pageRect!, nil)
                    let ctx = UIGraphicsGetCurrentContext()
                    ctx?.interpolationQuality = .high
                    // Draw existing page
                    ctx!.saveGState()
                    ctx!.scaleBy(x: 1, y: -1)
                    ctx!.translateBy(x: 0, y: -(pageRect?.size.height)!)
                    ctx!.drawPDFPage(page!)
                    ctx!.restoreGState()
                }
                UIGraphicsEndPDFContext()
            }
            return data as Data
        }
        return nil
    }
 */
}
