//
//  NSObject+MGSDisposable.m
//  KosmicTask
//
//  Created by Mitchell Jonathan on 09/03/2012.
//  Copyright (c) 2012 Mugginsoft. All rights reserved.
//

#import "NSObject+MGSDisposable.h"
#import <objc/runtime.h>

// enable logging
#define MGS_DISPOSAL_LOG

// disable logging
// comment the line below to enable logging
#undef MGS_DISPOSAL_LOG

static char mgsDisposableKey;
NSString * const MGSAllowDisposalKey = @"MGSAllowDisposal";
NSString * const MGSAllowDisposaValue = @"Yes";

@implementation NSObject (MGSDisposable)

/*
 
 - mgsMakeDisposable
 
 */
- (void)mgsMakeDisposable
{
    
#ifdef MGS_DISPOSAL_LOG
    [self mgsLogSelector:_cmd];
#endif 
    
    // check if already disposable
    if ([self isMgsDisposable]) {
        return;
    }
    
    // assign an initial reference count of 1
    NSNumber *refCount = [NSNumber numberWithUnsignedInteger:1];
    [self mgsAssociateValue:refCount withKey:&mgsDisposableKey];
}

/*
 
 - isMgsDisposable
 
 */
- (BOOL)isMgsDisposable
{
    return ([self mgsDisposalCount] == NSUIntegerMax ? NO : YES);
}

/*
 
 - mgsDisposalCount
 
 */
- (NSUInteger)mgsDisposalCount
{
    NSNumber *refCount = [self mgsAssociatedValueForKey:&mgsDisposableKey];
    if (!refCount) {
        return NSUIntegerMax;
    }
    
    return [refCount unsignedIntegerValue];
}

/*
 
 - isMgsDisposed
 
 */
- (BOOL)isMgsDisposed
{
    NSUInteger refCount = [self mgsDisposalCount];
    return (refCount == 0 ? YES : NO);
}

/*
 
 - mgsRetainDisposable
 
 */
- (void)mgsRetainDisposable
{
    
#ifdef MGS_DISPOSAL_LOG
    [self mgsLogSelector:_cmd];
#endif 
    
    if (![self isMgsDisposable]) return;
    if ([self isMgsDisposed]) return;
    
    NSUInteger refCount = [self mgsDisposalCount];
    if (refCount == NSUIntegerMax) {
        return;
    }
    
    [self mgsAssociateValue:[NSNumber numberWithUnsignedInteger:++refCount] withKey:&mgsDisposableKey];
}

/*
 
 - mgsReleaseDisposable
 
 */
- (void)mgsReleaseDisposable
{
    
#ifdef MGS_DISPOSAL_LOG
    [self mgsLogSelector:_cmd];
#endif   
    
    if (![self isMgsDisposable]) return;
    if ([self isMgsDisposed]) return;
    
    NSUInteger refCount = [self mgsDisposalCount];
    if (refCount == NSUIntegerMax) {
        return;
    }

    // dispose when reference count == 1
    if (refCount == 1) {
        [self mgsAssociateValue:MGSAllowDisposaValue withKey:MGSAllowDisposalKey];
        [self mgsDispose];
    } else {
        [self mgsAssociateValue:[NSNumber numberWithUnsignedInteger:--refCount] withKey:&mgsDisposableKey];
    }
}

/*
 
 - mgsDispose
 
 */
- (void)mgsDispose
{
    
#ifdef MGS_DISPOSAL_LOG
    [self mgsLogSelector:_cmd];
#endif
    
    // we must be disposable
    if (![self isMgsDisposable]) return;
    
    // log and quit if already disposed
    if ([self isMgsDisposedWithLogIfTrue]) return;
    
    // disposal is only valid when the allow disposal key is found
    if (![self mgsAssociatedValueForKey:MGSAllowDisposalKey]) {
        NSLog(@"Disposal is not valid at this time.");
        return;
    }
    
    // mark this object as disposed
    [self mgsAssociateValue:[NSNumber numberWithUnsignedInteger:0] withKey:&mgsDisposableKey];
    
    // remove the allow disposal key
    [self mgsAssociateValue:nil withKey:MGSAllowDisposalKey];
}

/*
 
 - isMgsDisposedWithLogIfTrue
 
 */
- (BOOL)isMgsDisposedWithLogIfTrue
{
    if (![self isMgsDisposable]) return NO;
    
    BOOL disposed = [self isMgsDisposed];
    if (disposed) {
        NSLog(@"mgsDispose already called.");
    }
    
    return disposed;
}

/*
 
 - mgsAssociateValue
 
 */
- (void)mgsAssociateValue:(id)value withKey:(void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

/*
 
 - mgsWeaklyAssociateValue
 
 */
- (void)mgsWeaklyAssociateValue:(id)value withKey:(void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

/*
 
 - mgsAssociatedValueForKey
 
 */
- (id)mgsAssociatedValueForKey:(void *)key
{
	return objc_getAssociatedObject(self, key);
}

/*
 
 - mgsLogSelector:
 
 */
- (void)mgsLogSelector:(SEL)sel
{
     NSLog(@"%@ received %@.", self, NSStringFromSelector(sel));
}

@end
