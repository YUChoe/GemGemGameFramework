//
//  ggGem.m
//  gemgemCCScene
//
//  Created by Yong-uk Choe on 12. 11. 24..
//
//

#import "ggGem.h"

@implementation ggGem

-(id)init {
  if ( self = [super init] ) {
    _obj = [[NSMutableArray alloc] init];
    // 구현 나중에
  }
  return self;
}

-(id)initAsTest:(int)testValue {
  if ( self = [super init] ) {
    _obj = [[NSMutableArray alloc] init];
  
    CCSprite *s = [CCSprite spriteWithFile:@"1.png"];
    [_obj addObject:s];
    
  }
  return self;
}

-(id)getObject {
  return _obj;
}

@end