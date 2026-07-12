//
//  ObjC.h
//  tower-ios
//
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

#ifndef ObjC_h
#define ObjC_h

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

#endif /* ObjC_h */
