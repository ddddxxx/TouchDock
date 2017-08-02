//
//  DeprecatedCarbonAPI.c
//
//  This file is part of TouchDock
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#include "DeprecatedCarbonAPI.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

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

#pragma GCC diagnostic pop
