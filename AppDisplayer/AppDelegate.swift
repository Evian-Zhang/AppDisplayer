//
//  AppDelegate.swift
//  AppDisplayer
//
//  Created by Evian张 on 2019/6/9.
//  Copyright © 2019 Evian张. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var exportButton: NSButton!
    @IBOutlet weak var importButton: NSButton!
    
    let baseImageName = "Module"
    var baseImage: NSImage?
    var processingImage: NSImage?
    var processedImage: NSImage?
    var processRect = NSMakeRect(222, 144, 1464, 917)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.exportButton.action = #selector(handleExport)
        self.exportButton.target = self
        self.exportButton.isEnabled = false
        
        self.importButton.action = #selector(handleImort)
        self.importButton.target = self
        
        self.baseImage = NSImage(named: baseImageName)
        self.imageView.image = self.baseImage
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @objc func handleExport() {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["png", "jpg", "jpeg"]
        savePanel.allowsOtherFileTypes = false
        savePanel.beginSheetModal(for: self.window!) { (modalReponse) -> Void in
            switch modalReponse {
            case .OK:
            let selectedURL = savePanel.url
            do {
            try self.processedImage?.tiffRepresentation?.write(to: selectedURL!)
            } catch { }
            
            default:
            break
            }
        }
    }
    
    @objc func handleImort() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg"]
        
        openPanel.beginSheetModal(for: self.window!) { (modalReponse) -> Void in
            switch modalReponse {
            case .OK:
                let selectedURL = openPanel.url
                self.processingImage = NSImage(contentsOf: selectedURL!)
                self.processImage()
                self.imageView!.image = self.processedImage
                self.exportButton.isEnabled = true
                
            default:
                break
            }
        }
    }
    
    func processImage() {
        let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(self.baseImage!.size.width), pixelsHigh: Int(self.baseImage!.size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bitmapFormat: .alphaFirst, bytesPerRow: 0, bitsPerPixel: 0)
        let graphicContext = NSGraphicsContext(bitmapImageRep: bitmapImageRep!)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicContext
        
        self.baseImage!.draw(in: NSMakeRect(0, 0, self.baseImage!.size.width, self.baseImage!.size.height))
        
        let xScale = self.processRect.width / self.processingImage!.size.width
        let yScale = self.processRect.height / self.processingImage!.size.height
        if xScale < yScale {
            self.processingImage!.draw(in: NSMakeRect(self.processRect.origin.x, self.processRect.origin.y, self.processRect.width, self.processingImage!.size.height * yScale))
        } else if xScale == yScale {
            self.processingImage!.draw(in: NSMakeRect(self.processRect.origin.x, self.processRect.origin.y, self.processRect.width, self.processRect.height))
        } else {
            self.processingImage!.draw(in: NSMakeRect(self.processRect.origin.x, self.processRect.origin.y, self.processingImage!.size.width * xScale, self.processRect.height))
        }
        
        NSGraphicsContext.restoreGraphicsState()
        
        self.processedImage = NSImage(size: self.baseImage!.size)
        self.processedImage?.addRepresentation(bitmapImageRep!)
    }

}

