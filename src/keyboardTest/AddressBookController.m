//
//  AddressBookController.m
//  KannuuSample
//
//  Created by Waqar Malik on 5/2/15.
//  Copyright (c) 2015 Waqar Malik. All rights reserved.
//

#import "AddressBookController.h"
@import AddressBook;
@import AddressBookUI;

#define kCRXDefaultSizeForIndexStrings	40
#define kCRXDefaultNamePriority			3
#define kCRXNickNamePriority			2
#define kCRXJobTitlePriority			1
#define kCRXCompanyOnlyPriority			10
#define kCRXSpaceString				@" "
#define kCRXCommmaString			@","
#define kCRXBlankSpaceString		@"☐"
#define kCRXFieldSeperatorString	@"♦"

typedef NS_ENUM(NSInteger, CRXIndexPriorityType)
{
    CRXIndexPriorityTypeFirstName = 0,
    CRXIndexPriorityTypeLastName
};

typedef NS_ENUM(NSInteger, CRXCaseSensitiveType)
{
    CRXCaseSensitiveTypeNormal = 0,
    CRXCaseSensitiveTypeLower,
    CRXCaseSensitiveTypeUpper
};

void refreshAddressBookProcedure(ABAddressBookRef addressBook, CFDictionaryRef info, void* context)
{
}

@interface AddressBookController ()
@property (strong, nonatomic, readwrite) KannuuIndexController *lookupController;
@property (nonatomic, strong) KannuuIndexController	*indexController;
@property (nonatomic, assign, readwrite) ABAddressBookRef addressBook;
@end

@implementation AddressBookController
+ (instancetype)sharedController
{
    static AddressBookController *gShareController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gShareController = [[AddressBookController alloc] init];
    });
    
    return gShareController;
}

+ (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

+ (NSString *)indexFile
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"ABSample"];
}

- (void)dealloc
{
    if(NULL != self.addressBook)
    {
        ABAddressBookUnregisterExternalChangeCallback(_addressBook, refreshAddressBookProcedure, (__bridge void *)(self));
        CFRelease(self.addressBook);
    }
}

- (void)askPermissionsWithCompletion:(AddressBookControllerBlock)completion
{
    CFErrorRef error = nil;
    self.addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if(NULL != self.addressBook)
    {
        ABAddressBookRegisterExternalChangeCallback(self.addressBook, refreshAddressBookProcedure, (__bridge void *)self);
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
            if(YES == granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *filePath = [self.class indexFile];
                    [self createIndexFromAddresseBookAtPath:filePath];
                    self.indexController = nil;
                    self.lookupController = [[KannuuIndexController alloc] initWithControllerMode:KannuuControllerModeLookup indexFilePath:filePath numberOfOptions:9];
                    if (completion)
                    {
                        completion(YES);
                    }
                });
            } else {
                if (completion)
                {
                    completion(NO);
                }
                // show error
            }
        });
    } else if (completion) {
        completion(NO);
    }
}

- (void)createIndexFromAddresseBookAtPath:(NSString *)indexPath
{
    @autoreleasepool
    {
        NSInteger count = ABAddressBookGetPersonCount(self.addressBook);
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
        NSString *indexFile = [self.class indexFile];

        _indexController = [[KannuuIndexController alloc] initWithControllerMode:KannuuControllerModeCreate indexFilePath:indexFile numberOfOptions:9];
        for(int i = 0; i < count; i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(people, i);
            [self addRecord:person changeCase:NO];
        }
        
        CFRelease(people);
    }
}

- (void)addRecord:(ABRecordRef)record changeCase:(CRXCaseSensitiveType)changeCase
{
    NSError				*error = nil;
    NSMutableString		*lfmName = [NSMutableString stringWithCapacity:kCRXDefaultSizeForIndexStrings];
    NSMutableString		*fmlName = [NSMutableString stringWithCapacity:kCRXDefaultSizeForIndexStrings];
    NSNumber			*recordID = [NSNumber numberWithInt:ABRecordGetRecordID(record)];
    
    NSString			*firstName = [self stringForABPropertyID:kABPersonFirstNameProperty
                                                 record:record changeCase:changeCase];
    NSString			*lastName = [self stringForABPropertyID:kABPersonLastNameProperty
                                                record:record changeCase:changeCase];
    NSString			*middleName = [self stringForABPropertyID:kABPersonMiddleNameProperty record:record changeCase:changeCase];
    NSString			*company = [self stringForABPropertyID:kABPersonOrganizationProperty record:record changeCase:changeCase];
    NSString			*nickName = nil, *jobTitle = nil;
    
    // dont add nick name
    //nickName = [self stringForABPropertyID:kABPersonNicknameProperty record:record changeCase:changeCase];
    
    // dont add job title
    //jobTitle = [self stringForABPropertyID:kABPersonJobTitleProperty record:record changeCase:changeCase];
    
    if(nil != firstName)
    {
        [fmlName appendString:firstName];
        if([lfmName length] > 0)
            [lfmName appendString:kCRXCommmaString];
        [lfmName appendFormat:@" %@", firstName];
    }
    
    if(nil != middleName)
    {
        if([fmlName length] > 0)
            [fmlName appendString:kCRXSpaceString];
        [fmlName appendString:middleName];
        if([lfmName length] > 0)
            [lfmName appendString:kCRXSpaceString];
        [lfmName appendFormat:@"%@ ", middleName];
    }
    
    if(nil != lastName)
    {
        [fmlName appendFormat:@" %@", lastName];
    }
    
    if(nil != lastName)
    {
        [lfmName appendString:lastName];
    }
    
    if([fmlName length] > 0)
    {
        [fmlName setString:[fmlName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [self.indexController addIndex:fmlName
                               forData:[recordID stringValue] priority:kCRXDefaultNamePriority error:&error];
    }
    
    if([lfmName length] > 0 && [fmlName length] <= 0)
    {
        [lfmName setString:[lfmName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [self.indexController addIndex:lfmName
                               forData:[recordID stringValue] priority:kCRXDefaultNamePriority error:&error];
    }
    
    if(nil != nickName)
    {
        NSMutableArray		*objects = [NSMutableArray arrayWithCapacity:1];
        [objects addObject:[nickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        if([fmlName length] > 0)
            [objects addObject:fmlName];
        
        [self.indexController addIndicies:objects forData:[recordID stringValue] priority:kCRXNickNamePriority error:&error];
    }
    
    if(nil != jobTitle)
    {
        NSMutableArray		*objects = [NSMutableArray arrayWithCapacity:1];
        [objects addObject:[jobTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        if([fmlName length] > 0)
            [objects addObject:fmlName];
        
        [self.indexController addIndicies:objects forData:[recordID stringValue] priority:kCRXJobTitlePriority error:&error];
    }
    
    // dont add company
    company = nil;
    if(nil != company)
    {
        BOOL	add = YES;
        
        if([fmlName length] > 0)
        {
            [self.indexController addIndicies:[NSArray arrayWithObjects:[company stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], fmlName, nil]
                                      forData:[recordID stringValue] priority:kCRXDefaultNamePriority error:&error];
            add = NO;
        }
        
        if(add)
        {
            [self.indexController addIndicies:[NSArray arrayWithObjects:[company stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], KannuuLookupvCardSymbolString, nil]
                                      forData:[recordID stringValue] priority:1+kCRXCompanyOnlyPriority error:&error];
        }
    }
}

- (NSString *)stringForABPropertyID:(ABPropertyID)propertyID record:(ABRecordRef)record changeCase:(CRXCaseSensitiveType)changeCase
{
    CFStringRef value = ABRecordCopyValue(record, propertyID);
    NSString *valueString = nil;
    
    if(NULL != value)
    {
        switch(changeCase)
        {
            case CRXCaseSensitiveTypeUpper:
                valueString = [NSString stringWithString:[(__bridge NSString *)value uppercaseString]];
                break;
            case CRXCaseSensitiveTypeLower:
                valueString = [NSString stringWithString:[(__bridge NSString *)value lowercaseString]];
                break;
            default:
            case CRXCaseSensitiveTypeNormal:
                valueString = [NSString stringWithString:(__bridge NSString *)value];
                break;
        }
        CFRelease(value);
    }
    
    valueString = [valueString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [valueString isEqualToString:@""] ? nil : valueString;
}
@end