//
//  resizeTest.swift
//  PDFMarginTextView
//
//  Created by JC Nolan on 3/4/21.
//

import Cocoa
import PDFKit

class ResizePDF: NSObject {
    
    /// Prints command-line usage and exits with status 1.
    static private func printUsageAndExit() -> Never  {
        exit(status: 1, "Usage: \(ProcessInfo.processInfo.processName) inputPDF outputPDF width height")
    }

    /// Converts the specified file path into a file URL and returns it if it’s reachable.
    /// - Parameter path: The file path to convert into a URL. If relative, the returned URL is
    ///   relative to the process’s current working directory. If the path begins with a “~” or
    ///   “~*user*”, the tilde is expanded before converting it into a URL.
    /// - Returns: A file URL for the specified file path if it is reachable; `nil` otherwise.
    static private func validatedFileURL(forPath path: String) -> URL? {
        let url = URL(fileURLWithPath: path.expandingTildeInPath)
        
        guard let isReachable = try? url.checkResourceIsReachable() , isReachable else {
            return nil
        }
        
        return url
    }

    /// Parses the processes’s command-line arguments and returns them in a tuple. If an error
    /// occurs while parsing command-line arguments, prints an error message and exits.
    //
    /// - Returns: A tuple containing the command-line arguments.
    private static func parseCommandLineArguments() -> (inputURL: URL, outputURL: URL, outputSize: CGSize) {
        let userArguments = ProcessInfo.processInfo.userArguments
        guard userArguments.count == 4 else {
            printUsageAndExit()
        }
        
        let inputPath = userArguments[0]
        guard let inputURL = validatedFileURL(forPath: inputPath) else {
            exit(status: 2, "Could not open PDF \(inputPath)")
        }
        
        let outputFileURL = URL(fileURLWithPath: userArguments[1].expandingTildeInPath)
        
        let widthString = userArguments[2]
        guard let width = Double(widthString), width > 0 else {
            exit(status: 3, "Width \(widthString) is not a non-negative double")
        }

        let heightString = userArguments[3]
        guard let height = Double(heightString), width > 0 else {
            exit(status: 4, "Height \(heightString) is not a non-negative double")
        }

        return (inputURL, outputFileURL, CGSize(width: width, height: height))
    }

    static func resize(sourcePdf: PDFDocument? = nil, outsideLeft:CGFloat=0, insideLeft:CGFloat=0, top:CGFloat=0, bottom:CGFloat=0)->PDFDocument?
    {
        var destPdf:PDFDocument? = nil
        
        let homePath = FileManager.default.homeDirectoryForCurrentUser
        let desktopPath = homePath.appendingPathComponent("Desktop")
      //  print(desktopPath)
        
        // if no source document was provided, read the hard-coded test document
        var sourceFileUrl = (sourcePdf == nil) ?  Bundle.main.url(forResource: "HerMouseReadACatAndADuck", withExtension: "pdf") : nil
        guard sourcePdf != nil || sourceFileUrl != nil else { return nil }
        
        let outputFileUrl = desktopPath.appendingPathComponent("icon-gh-500-500.pdf")
        
        let (inputURL, outputURL, outputSize, outputMargin) = (
            sourceFileUrl,
            outputFileUrl,
            CGSize(width: (8.5+(outsideLeft+insideLeft))*72.0, height: (11.0+0.0)*72.0),
            CGSize(width: outsideLeft*72.0, height: bottom*72.0)
            )
        
        // Create and start a resize operation with those arguments
        // let operation = PDFResizeOperation(inputURL: inputURL, outputURL: outputURL, outputSize: outputSize)
        let operation = PDFResizeOperation(sourcePdf: sourcePdf,  inputURL: inputURL, outputURL: outputURL,
                                           outputSize: outputSize, outputMargin: outputMargin)
        operation.start()

        // If an error occurred, print an appropriate error message
        if let error = operation.error {
            switch error {
            case let .couldNotOpenFileURL(fileURL):
                print("Could not open input PDF \(fileURL.path.abbreviatingWithTildeInPath)")
//                exit(status: 5, "Could not open input PDF \(fileURL.path.abbreviatingWithTildeInPath)")
            case let  .couldNotCreateOutputPDF(fileURL):
                print("Could not create output PDF \(fileURL.path.abbreviatingWithTildeInPath)")
//                exit(status: 6, "Could not create output PDF \(fileURL.path.abbreviatingWithTildeInPath)")
            }
        } else {
            
            if let document = PDFDocument(url: outputFileUrl) {
                
                destPdf = document
                
                // Otherwise print success
                print("Successfully combined PDFs and saved output to \(outputURL.path.abbreviatingWithTildeInPath).")
            }
            
        }
        return destPdf
    }
}
