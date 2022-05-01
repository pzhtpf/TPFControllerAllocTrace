//
//  TPFIvarReference.m
//  TPFControllerAllocTrace
//
//  Created by Pengfei Tian on 2022/5/1.
//

#import "TPFIvarReference.h"

@implementation TPFIvarReference

- (instancetype)initWithIvar:(Ivar)ivar {
    if (self = [super init]) {
        _name = @(ivar_getName(ivar));
        _type = [self _convertEncodingToType:ivar_getTypeEncoding(ivar)];
        _offset = ivar_getOffset(ivar);
        _index = _offset / sizeof(void *);
        _ivar = ivar;
    }

    return self;
}

- (TPFType)_convertEncodingToType:(const char *)typeEncoding {
    if (typeEncoding[0] == '{') {
        return TPFStructType;
    }

    if (typeEncoding[0] == '@') {
        // It's an object or block

        // Let's try to determine if it's a block. Blocks tend to have
        // @? typeEncoding. Docs state that it's undefined type, so
        // we should still verify that ivar with that type is a block
        if (strncmp(typeEncoding, "@?", 2) == 0) {
            return TPFBlockType;
        }

        return TPFObjectType;
    }

    return TPFUnknownType;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@, index: %lu]", _name, (unsigned long)_index];
}

#pragma mark - TPFObjectReference

- (NSUInteger)indexInIvarLayout {
    return _index;
}

- (id)objectReferenceFromObject:(id)object {
    return object_getIvar(object, _ivar);
}

- (NSArray<NSString *> *)namePath {
    return @[@(ivar_getName(_ivar))];
}

@end
