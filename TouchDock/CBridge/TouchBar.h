//
//  TouchBar.h
//  TouchDock
//
//  Created by 邓翔 on 2017/6/3.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

#import <AppKit/AppKit.h>

extern void DFRElementSetControlStripPresenceForIdentifier(NSTouchBarItemIdentifier, BOOL);
extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);

@interface NSTouchBarItem ()

+ (void)addSystemTrayItem:(NSTouchBarItem *)item;

@end

@interface NSTouchBar ()

+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;

@end

extern CFArrayRef _LSCopyApplicationArrayInFrontToBackOrder(uint32_t sessionID);
extern void _LSASNExtractHighAndLowParts(void const* asn, UInt32* psnHigh, UInt32* psnLow);
extern CFTypeID _LSASNGetTypeID(void);
