/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import "Struct.h"
#import "Type.h"

namespace TPF { namespace RetainCycleDetector { namespace Parser {
  
  /**
   This function will parse a struct encoding from an ivar, and return an TPFParsedStruct instance.
   Check TPFParsedStruct to learn more on how to interact with it.
   
   TPFParseStructEncoding assumes the string passed to it will be a proper struct encoding.
   It will not work with encodings provided by @encode() because they do not add names.
   It will work with encodings provided by ivars (ivar_getTypeEncoding)
   */
  Struct parseStructEncoding(const std::string &structEncodingString);
  
  
  /**
   You can provide name for root struct you are passing. The name will be then used
   in typePath (check out TPFParsedType for details).
   The name here can be for example a name of an ivar with this struct.
   */
  Struct parseStructEncodingWithName(const std::string &structEncodingString,
                                     const std::string &structName);
  
  
} } }
