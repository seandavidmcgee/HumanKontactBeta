//
//  AddressBookController.h
//  KannuuSample
//
//  Created by Waqar Malik on 5/2/15.
//  Copyright (c) 2015 Waqar Malik. All rights reserved.
//

@import Foundation;
#import "KannuuIndexController.h"
typedef void (^AddressBookControllerBlock)(BOOL success);

@interface AddressBookController : NSObject
@property (strong, nonatomic, readonly) KannuuIndexController *lookupController;

+ (instancetype)sharedController;
- (void)askPermissionsWithCompletion:(AddressBookControllerBlock)completion;
@end
