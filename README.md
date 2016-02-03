# Reproduction of SwiftMongoDB `.find()` bug

*Fritz Anderson, fritza@mac.com*

This project is virtually unaltered from the standard Xcode no-doc-no-CD application template. All the work is done in `ViewController`.

When `ViewController` is initialized, it creates the `MongoDB` object, pointed at `test` in the usual local `mongod` instance. One thing to note is that I launched this from the command line, and did *not* twiddle the process and file descriptor limits as `mongo` requests.

At `viewDidLoad`, it creates references to two collections, `participants` and `reports`. Upon creation, the app removes all their documents (query is `[:]`). This way, we have a fresh start at each run.

## `@IBAction`

**File** > **New** calls through to `create(_:)`, which initializes four documents in the `participants` array, and inserts them. It puts the data from each into the “console” view, but that’s just the local data. The `mongo` console shows the docs did make it in.

This command is meant to be issued only once per run.

**File** > **Fetch** calls `retrieveAll(_:)`. This does an unconditional `.find` on the `participants` collection, and puts the results into the console view.

*Expected:* The view shows the `Dictionary.description` of four documents.

*Actual:* It shows one. The cursor loop in `MongoCollection.find(_:)` executes only once. The second fetch matches the document IDs and breaks the loop.

> If it were me, I’d preserve the distinction between `hasNext()` and `next()`. In a perfect world, I might have `MongoCursor` implement `SequenceType`. At first glance, it’s a decent fit.

## Environment

* Mac OS X “El Capitan” 10.11.3 (15D21)  
* Xcode Version 7.2 (7C68)  
* MongoDB shell version: 3.2.1  
* `mongod` 
    * installed from HomeBrew late January 2016, with SSL options.  
    * run with `--dbpath data/db` (in my home directory). No adjustments were made to process or descriptor limits.
    
---

    db version v3.2.1  
    git version: a14d55980c2cdc565d4704a7e3ad37e4e535c1b2  
    OpenSSL version: OpenSSL 1.0.2f  28 Jan 2016  
    allocator: system  
    modules: none  
    build environment:  
        distarch: x86_64  
        target_arch: x86_64  

