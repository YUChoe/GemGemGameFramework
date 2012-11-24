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
  }
  return self;
}

-(id)initAsTest:(int)testValue {
  if ( self = [super init] ) {
    _obj = [[NSMutableArray alloc] init];    
  }
  return self;
}

@end