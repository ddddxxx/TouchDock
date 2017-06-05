//
//  RunningApplications.c
//  TouchDock
//
//  Created by 邓翔 on 2017/6/3.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#include "RunningApplications.h"

/*
 * Returns an array of CFDictionaryRef types, each of which contains information about one of the processes.
 * The processes are ordered in front to back, i.e. in the same order they appear when typing command + tab, from left to right.
 * See the ProcessInformationCopyDictionary function documentation for the keys used in the dictionaries.
 * If something goes wrong, then this function returns NULL.
 */
CFArrayRef copyPIDArrayInFrontToBackOrder(void) {
    CFMutableArrayRef orderedApplications = CFArrayCreateMutable(kCFAllocatorDefault, 64, &kCFTypeArrayCallBacks);
    if (!orderedApplications) { return NULL; }
    
    CFArrayRef apps = _LSCopyApplicationArrayInFrontToBackOrder(-1);
    if (!apps) { CFRelease(orderedApplications); return NULL; }
    
    CFStringRef pidKey = CFStringCreateWithCString(kCFAllocatorDefault, "pid", kCFStringEncodingUTF8);
    
    CFIndex count = CFArrayGetCount(apps);
    for (CFIndex i = 0; i < count; i++) {
        ProcessSerialNumber psn = {0, kNoProcess};
        CFTypeRef asn = CFArrayGetValueAtIndex(apps, i);
        if (CFGetTypeID(asn) == _LSASNGetTypeID()) {
            _LSASNExtractHighAndLowParts(asn, &psn.highLongOfPSN, &psn.lowLongOfPSN);
            CFDictionaryRef processInfo = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
            if (processInfo) {
                CFNumberRef pid = CFDictionaryGetValue(processInfo, pidKey);
                if (pid) {
                    CFArrayAppendValue(orderedApplications, pid);
                    CFRelease(pid);
                }
                CFRelease(processInfo);
            }
        }
    }
    CFRelease(apps);
    
    CFRelease(pidKey);
    
    CFArrayRef result = CFArrayGetCount(orderedApplications) == 0 ? NULL : CFArrayCreateCopy(kCFAllocatorDefault, orderedApplications);
    CFRelease(orderedApplications);
    return result;
}
