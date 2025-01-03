//
//  ObjC.m
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-22.
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjC.h"

@implementation ObjC

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
        return NO;
    }
}

@end
