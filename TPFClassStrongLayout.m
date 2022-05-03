//
//  TPFClassStrongLayout.m
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/3.
//

#import "TPFClassStrongLayout.h"
#import <objc/runtime.h>
#import "TPFIvarReference.h"

@interface TPFClassStrongLayout ()

@property (weak, nonatomic) NSMutableDictionary *layoutCache;

@end

@implementation TPFClassStrongLayout

NSArray* TPFGetClassReferences(Class aCls)
{
    NSMutableArray *result = [NSMutableArray new];

    unsigned int count;
    Ivar *ivars = class_copyIvarList(aCls, &count);

    for (unsigned int i = 0; i < count; ++i) {
        Ivar ivar = ivars[i];
        TPFIvarReference *wrapper = [[TPFIvarReference alloc] initWithIvar:ivar];

        if (wrapper.type == TPFStructType) { /* 结构体的暂且先不处理 */
//      std::string encoding = std::string(ivar_getTypeEncoding(wrapper.ivar));
//      NSArray<TPFObjectInStructReference *> *references = TPFGetReferencesForObjectsInStructEncoding(wrapper, encoding);
//
//      [result addObjectsFromArray:references];
        } else {
            [result addObject:wrapper];
        }
    }
    free(ivars);

    return [result copy];
}

static NSIndexSet * TPFGetLayoutAsIndexesForDescription(NSUInteger minimumIndex, const uint8_t *layoutDescription)
{
    NSMutableIndexSet *interestingIndexes = [NSMutableIndexSet new];
    NSUInteger currentIndex = minimumIndex;

    while (*layoutDescription != '\x00') {
        int upperNibble = (*layoutDescription & 0xf0) >> 4;
        int lowerNibble = *layoutDescription & 0xf;

        // Upper nimble is for skipping
        currentIndex += upperNibble;

        // Lower nimble describes count
        [interestingIndexes addIndexesInRange:NSMakeRange(currentIndex, lowerNibble)];
        currentIndex += lowerNibble;

        ++layoutDescription;
    }

    return interestingIndexes;
}

static NSUInteger TPFGetMinimumIvarIndex(__unsafe_unretained Class aCls)
{
    NSUInteger minimumIndex = 1;
    unsigned int count;
    Ivar *ivars = class_copyIvarList(aCls, &count);

    if (count > 0) {
        Ivar ivar = ivars[0];
        ptrdiff_t offset = ivar_getOffset(ivar);
        minimumIndex = offset / (sizeof(void *));
    }

    free(ivars);

    return minimumIndex;
}

static NSArray * TPFGetStrongReferencesForClass(Class aCls)
{
    NSArray *ivars = [TPFGetClassReferences(aCls) filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[TPFIvarReference class]]) {
            TPFIvarReference *wrapper = evaluatedObject;
            return wrapper.type != TPFUnknownType;
        }
        return YES;
    }]];

    const uint8_t *fullLayout = class_getIvarLayout(aCls);

    if (!fullLayout) {
        return nil;
    }

    NSUInteger minimumIndex = TPFGetMinimumIvarIndex(aCls);
    NSIndexSet *parsedLayout = TPFGetLayoutAsIndexesForDescription(minimumIndex, fullLayout);

    NSArray *filteredIvars =
        [ivars filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (TPFIvarReference *evaluatedObject,
                                                                                  NSDictionary *bindings) {
                                                                                      return [parsedLayout containsIndex:[evaluatedObject indexInIvarLayout]];
                                                                                  }]];

    return filteredIvars;
}

- (NSArray *)getObjectStrongReferences:(id)obj layoutCache:(NSMutableDictionary *)layoutCache {
    NSMutableArray *array = [NSMutableArray new];

    __unsafe_unretained Class previousClass = nil;
    __unsafe_unretained Class currentClass = object_getClass(obj);

    while (previousClass != currentClass) {
        NSArray *ivars;

        if (layoutCache && currentClass) {
            ivars = layoutCache[currentClass];
        }

        if (!ivars) {
            ivars = TPFGetStrongReferencesForClass(currentClass);
            if (layoutCache && currentClass) {
                layoutCache[(id<NSCopying>)currentClass] = ivars;
            }
        }
        [array addObjectsFromArray:ivars];

        previousClass = currentClass;
        currentClass = class_getSuperclass(currentClass);
    }

    return [array copy];
}

@end
