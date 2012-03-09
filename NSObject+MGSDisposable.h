//
//  NSObject+MGSDisposable.h
//
//  Created by Jonathan Mitchell on 09/03/2012.
//  
//  Licence: MIT

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
