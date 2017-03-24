//
//  ObjC.m
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 3/24/17.
//  Copyright © 2017 pixelmaid. All rights reserved.
//

#import "ObjC.h"

@implementation ObjC

+ (BOOL)catchException:(void(^)())tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
    }
}

@end
