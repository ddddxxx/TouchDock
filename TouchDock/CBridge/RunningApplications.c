//
//  RunningApplications.c
//  TouchDock
//
//  Created by 邓翔 on 2017/6/3.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#include "RunningApplications.h"

CFStringRef kPidKey = CFSTR("pid");

CFNumberRef pidFromASN(void const *asn) {
    ProcessSerialNumber psn = {0, kNoProcess};
    if (CFGetTypeID(asn) == _LSASNGetTypeID()) {
        _LSASNExtractHighAndLowParts(asn, &psn.highLongOfPSN, &psn.lowLongOfPSN);
        CFDictionaryRef processInfo = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
        if (processInfo) {
            CFNumberRef pid = CFDictionaryGetValue(processInfo, kPidKey);
            CFRelease(processInfo);
            return pid;
        }
    }
    return nil;
}
