//
//  LaunchApplications.h
//  TouchDock
//
//  Created by 邓翔 on 2017/6/3.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <dlfcn.h>

extern CFArrayRef _LSCopyApplicationArrayInFrontToBackOrder(uint32_t sessionID);
extern void _LSASNExtractHighAndLowParts(void const* asn, UInt32* psnHigh, UInt32* psnLow);
extern CFTypeID _LSASNGetTypeID(void);

CFArrayRef copyPIDArrayInFrontToBackOrder(void);
