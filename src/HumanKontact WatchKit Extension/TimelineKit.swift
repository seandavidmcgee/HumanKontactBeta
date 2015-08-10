//
//  TimelineKit.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Adrian Zubarev (a.k.a. DevAndArtist)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

/**
* Defining custom type names.
*/
typealias TimelineTimeInterval = Double
typealias Block = () -> Void

/**
* Enumeration to determinate blocks execution position.
*/
enum TimelineBlockAction
{
    case WillExecuteMainBlock
    case DidExecuteMainBlock
    case WillExecuteOptionalCompletionBlock
    case DidExecuteOptinalCompletionBlock
}

/**
*  A helper class to create unchained blocks with delays.
*/
private class TimelineBlock
{
    /// This property is needed to force strong reference to the timeline,
    /// so the timeline object won't be deallocated while the block is executing.
    /// This also provides a possibility for delegation.
    var timeline: Timeline!
    
    /// This property will contain the computed block which will be executed.
    var block: Block!
    
    /// This property can hold a reference to the successor block which is appended
    /// to the end of the 'block's execution.
    var successor: Block!
    
    /// Property that determinates the number of the block inside the queue.
    var number: Int = 0
    
    /**
    Main initializer to create a TimelineBlock object and compute the 'block' property.
    
    :param: delay      Time to wait before 'execution' block is triggered.
    :param: duration   Time assumed by the developer the 'execution' block will take.
    :param: execution  The main block.
    :param: completion An optional completion block which is triggered after duration time.
    
    :returns: TimelineBlock object.
    */
    init(delay: TimelineTimeInterval, duration: TimelineTimeInterval, execution: Block, completion: Block!)
    {
        let completionAndSuccessorBlock: Block = {
            
            [weak self] in
            
            if let weakSelf = self
            {
                weakSelf.timeline.notifyDelagesWithBlock(number: weakSelf.number, action: .WillExecuteOptionalCompletionBlock)
                
                if let completionBlock = completion
                {
                    completionBlock()
                }
                
                weakSelf.timeline.notifyDelagesWithBlock(number: weakSelf.number, action: .DidExecuteOptinalCompletionBlock)
                
                if let successor = weakSelf.successor
                {
                    successor()
                }
            }
        }
        
        let blockToExecute: Block = {
            
            [weak self] in
            
            if let weakSelf = self
            {
                weakSelf.timeline.notifyDelagesWithBlock(number: weakSelf.number, action: .WillExecuteMainBlock)
                
                execution()
                
                weakSelf.timeline.notifyDelagesWithBlock(number: weakSelf.number, action: .DidExecuteMainBlock)
                
                if duration <= 0.0 { completionAndSuccessorBlock(); return }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue())
                    {
                        completionAndSuccessorBlock()
                }
            }
        }
        
        self.block = {
            
            [weak self] in
            
            if let weakSelf = self
            {
                if delay <= 0.0 { blockToExecute(); return }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue())
                    {
                        blockToExecute()
                }
            }
        }
    }
    
    /**
    Deinitializer to show that the object is released when it is no more needed.
    Add "-D DEBUG" at 'Build Settings' -> 'Swift Compiler - Custom Flags' -> 'Other Swift Flags'.
    */
    deinit
    {
        #if DEBUG
            println("      ◎--○--: Deallocated (\(number + 1)) TimelineBlock")
        #endif
    }
}

/**
* A queue to create TimelineBlocks array from inside a timeline block.
*/
class TimelineQueue
{
    /**
    Adds an execution block and maybe adds a completion block if it is not nil with a delay and duration to the queue.
    
    :param: delay      Time to wait before 'execution' block is triggered.
    :param: duration   Time assumed by the developer the 'execution' block will take.
    :param: execution  The main block.
    :param: completion An optional completion block which is triggered after duration time.
    */
    final func add(#delay: TimelineTimeInterval, duration: TimelineTimeInterval, execution: Block, completion: Block!)
    {
        let timelineBlock = TimelineBlock(delay: delay, duration: duration, execution: execution, completion: completion)
        
        timelineBlock.number = blocks.count
        
        blocks.append(timelineBlock)
    }
    
    /**
    Adds an execution block with a delay and duration to the queue.
    
    :param: delay      Time to wait before 'execution' block is triggered.
    :param: duration   Time assumed by the developer the 'execution' block will take.
    :param: execution  The main block.
    */
    final func add(#delay: TimelineTimeInterval, duration: TimelineTimeInterval, execution: Block)
    {
        self.add(delay: delay, duration: duration, execution: execution, completion: nil)
    }
    
    final private var blocks = [TimelineBlock]()
    
    /**
    Adds an execution block with a delay to the queue.
    
    :param: delay      Time to wait before 'execution' block is triggered.
    :param: execution  The main block.
    */
    final func add(#delay: TimelineTimeInterval, execution: Block)
    {
        self.add(delay: delay, duration: 0.0, execution: execution, completion: nil)
    }
    
    /**
    Deinitializer to show that the object is released when it is no more needed.
    Add "-D DEBUG" at 'Build Settings' -> 'Swift Compiler - Custom Flags' -> 'Other Swift Flags'.
    */
    deinit
    {
        #if DEBUG
            println("   ◎--○--: Deallocated TimelineQueue")
        #endif
    }
}

/**
*  A timeline delegation protocol.
*/
protocol TimelineDelegate
{
    /**
    This method is called while the timeline is executing all blocks and returns all block actions.
    
    :param: timeline    Timeline object reference.
    :param: identifier  An optional timeline identifier.
    :param: blockNumber The number which determinates the block index inside the queue.
    :param: blockAction Block action to derminate execution position.
    */
    func timeline(timeline: Timeline, identifier: String?, blockNumber: Int, blockAction: TimelineBlockAction)
}

/**
*  Timeline class.
*/
class Timeline
{
    /**
    Creates a standalone timeline with a single execution block after a delay for specified duration
    time with an optional completion block.
    
    :param: identifier Optional timeline identifier.
    :param: delay      Time to wait before 'execution' block is triggered.
    :param: duration   Time assumed by the developer the 'execution' block will take.
    :param: execution  The main block.
    :param: completion An optional completion block which is triggered after duration time.
    
    :returns: Returns the timeline object.
    */
    final class func with(identifier: String! = nil, delay: TimelineTimeInterval, duration: TimelineTimeInterval, execution: Block, completion: Block) -> Timeline
    {
        let timeline = Timeline()
        
        timeline.identifier = identifier
        timeline.queue.add(delay: delay, duration: duration, execution: execution, completion: completion)
        
        return timeline
    }
    
    /**
    Creates a standalone timeline with a single execution block after a delay.
    
    :param: identifier Optional timeline identifier.
    :param: delay      Time to wait before 'execution' block is triggered.
    :param: execution  The main block.
    
    :returns: Returns the timeline object.
    */
    final class func with(identifier: String! = nil, delay: TimelineTimeInterval, execution: Block) -> Timeline
    {
        let timeline = Timeline()
        
        timeline.identifier = identifier
        timeline.queue.add(delay: delay, duration: 0.0, execution: execution)
        
        return timeline
    }
    
    /**
    Creates a standalone timeline from a timeline queue.
    
    :param: identifier Optional timeline identifier.
    :param: block      Block where you can add blocks to a queue.
    
    :returns: Returns the timeline object.
    */
    final class func with(identifier: String! = nil, block: (queue: TimelineQueue) -> Void) -> Timeline
    {
        let timeline = Timeline()
        
        timeline.identifier = identifier
        
        block(queue: timeline.queue)
        
        return timeline
    }
    
    /// Property with all delates.
    final private var delegates = [TimelineDelegate]()
    
    /// Queue property
    final private var queue = TimelineQueue()
    
    /// Amout of timeline runs (is > 1 if .start is called to quickly and to often)
    final private var runs = 0
    
    /// Flag that determinates if the blocks are executing.
    final private var isRunning = false
    
    /// The optional identifier property.
    final private var identifier: String?
    
    /// Property which is used as a starting function for the timeline.
    final internal var start: Void
        {
            runs += 1
            run()
    }
    
    /**
    Main starting function which chains the blocks to gether and executes the root block.
    */
    private func run()
    {
        if !isRunning
        {
            for index in 0 ..< queue.blocks.count
            {
                let timelineBlock = queue.blocks[index]
                
                timelineBlock.timeline = self
                
                if index < queue.blocks.count - 1
                {
                    if timelineBlock.successor == nil
                    {
                        timelineBlock.successor = queue.blocks[index + 1].block
                    }
                }
            }
            
            queue.blocks[0].block()
            isRunning = true
        }
    }
    
    /**
    Adds a delate to the timeline object.
    
    :param: delegate Delegate reference.
    */
    func addDelegate(delegate: TimelineDelegate)
    {
        if !delegates.containsObject(delegate) // uses a custom array extension
        {
            delegates.append(delegate)
        }
    }
    
    /**
    Removes a delage from the timeline object.
    
    :param: delegate Delegate reference.
    */
    func removeDeleage(delegate: TimelineDelegate)
    {
        if delegates.containsObject(delegate) // uses a custom array extension
        {
            delegates.removeObject(delegate) // uses a custom array extension
        }
    }
    
    /**
    Private method which is called from each block to notify a possible delagate with its action.
    
    :param: number Block index in the timeline queue.
    :param: action Action of the block.
    */
    private func notifyDelagesWithBlock(#number: Int, action: TimelineBlockAction)
    {
        for delegate in delegates
        {
            delegate.timeline(self, identifier: identifier, blockNumber: number, blockAction: action)
        }
        
        if action == .DidExecuteOptinalCompletionBlock
        {
            queue.blocks[number].timeline = nil
            
            if number == queue.blocks.count - 1
            {
                runs -= 1
                isRunning = false
                
                if runs > 0 { run() }
            }
        }
    }
    
    /**
    Deinitializer to show that the object is released when it is no more needed.
    Add "-D DEBUG" at 'Build Settings' -> 'Swift Compiler - Custom Flags' -> 'Other Swift Flags'.
    */
    deinit
    {
        #if DEBUG
            println("◎--○--: Deallocated Timeline")
        #endif
    }
}

/**
* Custom Array extention.
*/
extension Array
{
    /**
    Checks if an array contains an object or not.
    
    :param: object Object to find inside the array.
    
    :returns: Returns a boolean to determinate if the object is inside the array or not.
    */
    func containsObject(object: Any) -> Bool
    {
        if let anObject: AnyObject = object as? AnyObject
        {
            for obj in self
            {
                if let anObj: AnyObject = obj as? AnyObject
                {
                    if anObj === anObject { return true }
                }
            }
        }
        
        return false
    }
    
    /**
    Searches for an object inside the array and removes it if it was found.
    
    :param: object Object to find inside the array.
    */
    mutating func removeObject(object: Any)
    {
        if let anObject: AnyObject = object as? AnyObject
        {
            for index in 0 ..< self.count
            {
                if let anObj: AnyObject = self[index] as? AnyObject
                {
                    if anObj === anObject
                    {
                        self.removeAtIndex(index)
                    }
                }
            }
        }
    }
}