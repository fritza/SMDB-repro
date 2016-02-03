//
//  ViewController.swift
//  killmeMongo
//
//  Created by Fritz Anderson on 2/2/16.
//  Copyright © 2016 The University of Chicago. All rights reserved.
//

import Cocoa
import SwiftMongoDB

class ViewController: NSViewController {
    let database = MongoDB(database: "test")
    var collections: [String: MongoCollection] = [:]
    static let collectionNames = [
        "participants", "reports"
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for name in ViewController.collectionNames {
            do {
                let collection = MongoCollection(name: name, mongo: database)
                
                collections[name] = collection
                try collection.remove([:] as DocumentData)
            }
            catch {
                print("Drop problem with collection", name)
            }
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    let participants: [DocumentData] = [
        [
            "uuid" : NSUUID().UUIDString,
            "name" : "Shouldn’t keep this on file",
            "born" : NSDate.fromShortDate("9/8/1920")!.iso8601,
            "applied" : NSDate().iso8601,
            "in_school" : true,
            "status" : "rejected"
        ],
        [
            "uuid" : NSUUID().UUIDString,
            "name" : "I should stop asking",
            "born" : NSDate.fromShortDate("9/8/2002")!.iso8601,
            "applied" : NSDate().iso8601,
            "in_school" : false,
            "status" : "rejected"
        ],
        [
            "uuid" : NSUUID().UUIDString,
            "name" : "I should stop asking",
            "born" : NSDate.fromShortDate("9/8/1999")!.iso8601,
            "applied" : NSDate().iso8601,
            "in_school" : true,
            "status" : "accepted"
        ],
        [
            "uuid" : NSUUID().UUIDString,
            "name" : "Still shouldn’t have one",
            "born" : NSDate.fromShortDate("10/22/2001")!.iso8601,
            "applied" : NSDate().iso8601,
            "in_school" : true,
            "status" : "accepted"
        ],
        
    ]

    @IBOutlet var console: NSTextView!
    
}


// MARK: - IBAction
extension ViewController {
    @IBAction func create(sender: AnyObject?) {
        let collection = collections["participants"]!
        let descriptions = participants
            .map { MongoDocument($0) }
            .map { try? collection.insert($0) }
            .map { $0?.data.description ?? "nil" }
        setConsoleContent(descriptions)
    }
    
    @IBAction func retrieveAll(sender: AnyObject?) {
        let collection = collections["participants"]!
        do {
            let found = try collection.find().map { $0.data.description }
            setConsoleContent(found)
        }
        catch {
            print("Failed to find")
            setConsoleContent("abject failure. I’m an abject failure.")
        }
    }
}

// MARK: - Console
extension ViewController {
    @objc(setConsoleContentWithString:)
    func setConsoleContent(content: String) {
        let newAttrString = NSAttributedString(
            string: content,
            attributes: [NSFontAttributeName: NSFont(name: "Menlo", size: 13)!])
        console.textStorage?.setAttributedString(newAttrString)
    }
    
    @objc(setConsoleContentWithStrings:)
    func setConsoleContent(content: [String]) {
        let newString = content.joinWithSeparator("\n\n")
        setConsoleContent(newString)
    }
    
    func appendConsoleContent(content: [String]) {
        var fullContent = [console.textStorage!.string]
        fullContent.appendContentsOf(content)
        
        let newString = content.joinWithSeparator("\n\n")
        let newAttrString = NSAttributedString(
            string: newString,
            attributes: [NSFontAttributeName: NSFont(name: "Menlo", size: 13)!])
        console.textStorage!.setAttributedString(newAttrString)
    }
}

// MARK: - Date utilities

let POSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
var iso8601DateFormatter: NSDateFormatter = {
    let retval = NSDateFormatter()
    retval.locale = POSIXLocale
    retval.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    retval.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    retval.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    return retval
}()

var shortDateFormatter: NSDateFormatter = {
    let retval = NSDateFormatter()
    retval.dateStyle = .ShortStyle
    return retval
}()


extension NSDate {
    // MARK: Formatting
    public var iso8601: String {
        return iso8601DateFormatter.stringFromDate(self)
    }
    
    public static func fromISO8601(iso8601: String) -> NSDate? {
        return iso8601DateFormatter.dateFromString(iso8601)
    }
    
    static func fromShortDate(shortDate: String) -> NSDate? {
        return shortDateFormatter.dateFromString(shortDate)
    }
}

