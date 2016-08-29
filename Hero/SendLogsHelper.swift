//
//  SendLogsHelper.swift
//  Hero
//
//  Created by Nissan Tsafrir on 24/08/2016.
//

import Foundation
import MessageUI
import CocoaLumberjack

public class SendLogsController: NSObject {

    static var fileLogger: DDFileLogger?
    
    var mailComposeDelegate: MFMailComposeViewControllerDelegate?
    
    class LogFile {
        let fileName: String
        let data: NSData
        
        init(fileName: String, data: NSData) {
            self.fileName = fileName
            self.data = data
        }
    }
    
    public func sendLogs() {
    
        guard let fileLogger = SendLogsController.fileLogger else {
            print("Missing Logger")
            return
        }
        
        fileLogger.rollLogFileWithCompletionBlock { 
            dispatch_async(dispatch_get_main_queue()) {
                self.didRollLogFiles()
            }
        }
    }
    
    private func didRollLogFiles() {
        guard let fileLogger = SendLogsController.fileLogger else {
            print("Missing Logger")
            return
        }
        let fileManager: DDLogFileManager = fileLogger.logFileManager
        
        var logFiles: [LogFile] = []
        
        if let files = fileManager.sortedLogFileInfos() as? [DDLogFileInfo] {
            for fileInfo in files {
                if let data = NSData(contentsOfFile: fileInfo.filePath) {
                    logFiles.append(LogFile(fileName: fileInfo.fileName, data: data))
                }
            }
        }
        
        if logFiles.count > 0 {
            sendLogsWithFiles(Array(logFiles.prefix(2)))
        } else {
            print("Error: no valid log files to send")
        }
    }
    
    private func sendLogsWithFiles(logFiles: [LogFile]) {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        
        let name = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as! String
        let bundleVersion = NSBundle.mainBundle().infoDictionary![kCFBundleVersionKey as String] as! String //CFBundleGetVersionNumber
        let subject = "[Report Problem] Logs for '\(name)' (\(bundleVersion))"
        vc.setSubject(subject)
        vc.setToRecipients(["nissan@pixandbyte.com"])
        
        guard let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController else { return }
        
        mailComposeDelegate = self
        vc.mailComposeDelegate = mailComposeDelegate
        
        vc.setMessageBody(appInfo(), isHTML: false)
        
        for file in logFiles {
            vc.addAttachmentData(file.data, mimeType: "text/plain", fileName: file.fileName)
        }
        rootVC.presentViewController(vc, animated: true, completion: nil)
    }
    
    private func appInfo() -> String {
        let pi = NSProcessInfo.processInfo()
        
        let name = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as! String
        
        let info = "\n---\nname:\(name)\nversion:\(version())\nos: \(pi.operatingSystemVersionString)\nhostName:\(pi.hostName)"
        
        DDLogInfo("arguments: \(pi.arguments)")
        
        return info
    }
    
    private func version() -> String {
        let shortVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let bundleVersion = NSBundle.mainBundle().infoDictionary![kCFBundleVersionKey as String] as! String //CFBundleGetVersionNumber
        return "\(shortVersion) (\(bundleVersion))"
    }
}


// MFMailComposeViewControllerDelegate

extension SendLogsController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        print("mail reuslt: \(result.rawValue)")
        if result == MFMailComposeResultSent {
            print("email sent")
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        mailComposeDelegate = nil
    }
}
