//
//  HOM.m
//  SimpleHom
//
//  Created by Marcel Weiher on 1/15/09.
//  Copyright 2009-2014 Marcel Weiher. All rights reserved.
//
//  Permission to copy under the BSD open source license.
//  Permission granted to copy granted specifically to 6wunderkinder
//

#import "HOM.h"

#define DEFINE_HOM( msgname , returnType) \
-msgname {  return [HOM homWithTarget:self selector:@selector(msgname:) arg:nil isVoid:@encode(returnType)==@encode(void)];  }\
-(returnType)msgname:(NSInvocation*)invocation

#define DEFINE_HOM_WITH1ARG( msgname ,returnType ) \
-msgname:arg {  return [HOM homWithTarget:self selector:@selector(msgname:arg:) arg:arg isVoid:@encode(returnType)==@encode(void)];  }\
-(returnType)msgname:(NSInvocation*)invocation arg:arg


@interface HOM : NSProxy
{
	id      xxTarget;
	SEL     xxSelector;
    id      xxArg;
    BOOL    xxIsVoid;
}

@end

@implementation HOM

-xxinitWithTarget:aTarget selector:(SEL)newSelector arg:anArg isVoid:(BOOL)isVoid
{
	xxTarget=aTarget;
	xxSelector=newSelector;
    xxArg=anArg;
    xxIsVoid=isVoid;
	return self;
}


+homWithTarget:aTarget selector:(SEL)newSelector arg:anArg isVoid:(BOOL)isVoid
{
    return [[self alloc] xxinitWithTarget:aTarget selector:newSelector arg:anArg isVoid:(BOOL)isVoid];
}

-(void)forwardInvocation:(NSInvocation*)anInvocation
{
    [anInvocation setTarget:xxTarget];
    [anInvocation retainArguments];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id result=[xxTarget performSelector:xxSelector withObject:anInvocation withObject:xxArg];
#pragma clang diagnostic pop
    
    if (!xxIsVoid) {
        [anInvocation setReturnValue:&result];
    }
}

-methodSignatureForSelector:(SEL)aSelector
{
    if ( [xxTarget respondsToSelector:aSelector]) {
        return [xxTarget methodSignatureForSelector:aSelector];     //  base
    } else if ( [xxTarget respondsToSelector:@selector(firstObject)] ) {
        if (  [[xxTarget firstObject] respondsToSelector:aSelector] ) {
            return [[xxTarget firstObject] methodSignatureForSelector:aSelector];  // collect etc.
        } else {
            return [NSMethodSignature signatureWithObjCTypes:"@@:"];
        }
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];        // ifResponds
    }
}

@end

@implementation NSArray(hom)

DEFINE_HOM( collect , NSArray* )
{
	NSMutableArray *resultArray=[NSMutableArray array];
	for (id obj in self ) {
		id resultObject;
		[invocation invokeWithTarget:obj];
		[invocation getReturnValue:&resultObject];
		[resultArray addObject:resultObject];
	}
	return resultArray;
}

@end


@implementation NSObject(LittleMessageDispatch)

DEFINE_HOM_WITH1ARG(afterDelay, void)
{
    [invocation performSelector:@selector(invokeWithTarget:) withObject:self afterDelay:[arg doubleValue]];
}

DEFINE_HOM(onMainThread, void)
{
    [invocation performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:NO];
}

DEFINE_HOM(syncOnMainThread, void)
{
    [invocation performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
}


DEFINE_HOM_WITH1ARG(onThread, void)
{
    [invocation performSelector:@selector(invokeWithTarget:) onThread:arg withObject:self waitUntilDone:NO];
}

DEFINE_HOM(async, void)
{
    [invocation performSelectorInBackground:@selector(invokeWithTarget:) withObject:self];
}


DEFINE_HOM(ifResponds, void)
{
    if ( [self respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self];
    }
}


@end




