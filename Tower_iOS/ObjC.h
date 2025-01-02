//
//  ObjC.h
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-12-22.
//  Copyright © 2024 valo.media GmbH. All rights reserved.
//

#ifndef ObjC_h
#define ObjC_h

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

#endif /* ObjC_h */
