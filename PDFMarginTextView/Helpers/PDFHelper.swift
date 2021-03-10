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
    
    class open func getCGPDFDocumentFromPDFViaRW(_ source:PDFDocument)->CGPDFDocument? {
        
        // Converts by writing to a buffer and re-reading, ugh!
        
        let homePath = FileManager.default.homeDirectoryForCurrentUser
        let desktopPath = homePath.appendingPathComponent("Desktop")
        let tempFileUrl = desktopPath.appendingPathComponent("bufferPdf.pdf")
        
        source.write(to: tempFileUrl)
        let retVal = CGPDFDocument(tempFileUrl as CFURL)
        return retVal
    }
    
    class open func getCGPDFDocumentFromPDFViaMemory(_ source:PDFDocument)->CGPDFDocument? {
        
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
    //    let pdfData = Data(source)
        
    //    retVal = PDFDocument(data: pdfData)
        
        return retVal
    }
}
