//
//  HOM.h
//  SimpleHom
//
//  Created by Marcel Weiher on 1/15/09.
//  Copyright 2009-2014 Marcel Weiher. All rights reserved.
//
//  Permission to copy under the BSD open source license.
//

#import <Foundation/Foundation.h>


@interface NSArray(hom)

-collect;

@end

@interface NSObject(LittleMessageDispatch)

-async;
-afterDelay:delayNSNumber;
-onMainThread;
-syncOnMainThread;
-onThread:aThread;
-ifResponds;

@end
