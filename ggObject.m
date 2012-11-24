//
//  ggObject.m
//  gemgemCCScene
//
//  Created by Yong-uk Choe on 12. 11. 24..
//
//

#import "ggObject.h"

@implementation ggObject

-(id)initWithCCLayer:(CCLayer *)_layer {
  CCLOG(@"starting init gemgem framework %@", GEMGEM_VERSION);
  
  if ( self = [super init] ) {
    _config = [[NSMutableDictionary alloc] init];
    _thisCCLayer = _layer;
    
    [self loadDefaultConfiguration];
    
  } else {
    CCLOG(@"init failed : crash");
    exit(EXIT_FAILURE);
  }
  
  return self;
}

-(void)loadDefaultConfiguration {
  [self setConfig:@"GemTypeCount" value:[NSNumber numberWithInt:4]];
  [self setConfig:@"GemType_01" value:[[ggGem alloc] initAsTest:1]];
  [self setConfig:@"GemType_02" value:[[ggGem alloc] initAsTest:2]];
  [self setConfig:@"GemType_03" value:[[ggGem alloc] initAsTest:3]];
  [self setConfig:@"GemType_04" value:[[ggGem alloc] initAsTest:4]];

}

-(void) setConfig:(NSString *)keyString value:(NSObject *)valueObject {
  [_config setObject:valueObject forKey:keyString];
  CCLOG(@"config[%@]:%@", keyString, ([_config objectForKey:keyString] == nil) ? @"ok" : @"failed");
}

-(NSObject *) getConfig:(NSString *)keyString {
  NSObject *o = [_config objectForKey:keyString];
  if ( o == nil) {
    
    return nil;
  }
  
}

@end