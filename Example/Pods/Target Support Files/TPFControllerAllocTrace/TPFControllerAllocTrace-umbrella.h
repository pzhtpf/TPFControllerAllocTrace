#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TPFRetainCycleDetector.h"
#import "TPFControllerAllocTrace.h"
#import "TPFCycleRetainManager.h"
#import "TPFBlockStrongRelationDetector.h"
#import "TPFBlockStrongLayout.h"
#import "TPFBlockInterface.h"
#import "TPFClassStrongLayoutHelpers.h"

FOUNDATION_EXPORT double TPFControllerAllocTraceVersionNumber;
FOUNDATION_EXPORT const unsigned char TPFControllerAllocTraceVersionString[];

