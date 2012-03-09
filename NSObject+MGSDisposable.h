//
//  NSObject+MGSDisposable.h
//  KosmicTask
//
//  Created by Mitchell Jonathan on 09/03/2012.
//  Copyright (c) 2012 Mugginsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MGSDisposable)

- (void)mgsMakeDisposable;
- (BOOL)isMgsDisposable;
- (NSUInteger)mgsDisposalCount;
- (BOOL)isMgsDisposed;
- (void)mgsRetainDisposable;
- (void)mgsReleaseDisposable;
- (void)mgsDispose;
- (BOOL)isMgsDisposedWithLogIfTrue;
- (void)mgsAssociateValue:(id)value withKey:(void *)key;
- (void)mgsWeaklyAssociateValue:(id)value withKey:(void *)key;
- (id)mgsAssociatedValueForKey:(void *)key;
- (void)mgsLogSelector:(SEL)sel;
@end
