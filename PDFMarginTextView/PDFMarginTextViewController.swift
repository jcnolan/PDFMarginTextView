//
//  ViewController.swift
//  PDFMarginTextView
//
//  Created by JC Nolan on 3/3/21.
//

import Cocoa
import PDFKit

class PDFMarginTextViewController: NSViewController {
    
    // MARK: Outlets and Class Variables
    
    @IBOutlet var pdfView: PDFMarginTextView!
    @IBOutlet var commentText: NSTextField!
    @IBOutlet var pageNumLabel: NSTextField!
    
    var currentSelectionText: String? = nil
    var currentSelection: PDFSelection? = nil
    
    // MARK: PDF Navigation Handlers
    
    @IBAction func prevPageButtonClicked(_ sender: Any) {
        
        if let currPageNum = pdfView.currentPage?.pageRef?.pageNumber {
            
            let currPageNum = currPageNum - 1
            var newPageNum:Int
            
            if currPageNum > 0 {
                newPageNum = currPageNum - 1
            } else {
                newPageNum = pdfView.document!.pageCount
            }
            
            goToPage(pageNum: newPageNum)
        }
    }
    
    @IBAction func nextPageButtonClicked(_ sender: Any) {
        
        if let currPageNum = pdfView.currentPage?.pageRef?.pageNumber {
            
            let currPageNum = currPageNum
            var newPageNum: Int
            
            if currPageNum < pdfView.document!.pageCount {
                
                newPageNum = currPageNum + 1
                
            } else { newPageNum = 1 }
            
            goToPage(pageNum: newPageNum)
        }
    }
    
    func goToPage(pageNum: Int) {
        
        if let pdfPage = pdfView.document?.page(at: pageNum-1) {
            pdfView.go(to: pdfPage)
            updatePageNumDisplay()
        }
    }
    
    func updatePageNumDisplay() {
     
        if let currPageNum = pdfView.currentPage?.pageRef?.pageNumber,
           let numPages    = pdfView.document?.pageCount {
            pageNumLabel.stringValue = "Page \(currPageNum) of \(numPages)"
        }
    }
    
    // MARK: Comment Controls Handlers
    
    @IBAction func resetComments(_ sender: Any) {
        
        pdfView.resetComments()
    }
    
    @IBAction func saveComment(_ sender: Any) {
        
        let commentTextStr = commentText.stringValue
        if let currentSelection = self.currentSelection,
           commentTextStr != "" {
            
            pdfView.saveComment(commentText: commentTextStr, selection: currentSelection)
        }
    }
    
    @IBAction func exitAppRequested(_ sender: Any) {
        
        NSApplication.shared.terminate(self)
    }
    
    // MARK: Controller Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addObservers()
        
        guard let path = Bundle.main.url(forResource: "HerMouseReadACatAndADuck", withExtension: "pdf") else { return }

        if let document = PDFDocument(url: path) {
            pdfView.document = document
            updatePageNumDisplay()
        }
    }
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(selectCompleteNotification), object: nil, queue: OperationQueue.main) { (notification) in
            
            if let userInfo = notification.userInfo,
               let currentSelectionText = userInfo[currentSelectedTextKey] as? String,
               let currentSelection = userInfo[currentPDFSelectionKey] as? PDFSelection
            {
                self.currentSelectionText    = currentSelectionText
                self.currentSelection        = currentSelection
                self.commentText.stringValue = self.currentSelectionText!
            }
        }
    }

}
