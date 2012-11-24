//
//  ggObject.h
//  gemgemCCScene
//
//  Created by Yong-uk Choe on 12. 11. 24..
//
//

#import <Foundation/Foundation.h>
#import "ggConfig.h"
#import "ggGem.h"

@interface ggObject : NSObject
{
  NSMutableDictionary *_config;
  CCLayer *_thisCCLayer;
}

-(id)initWithCCLayer:(CCLayer *)_layer;

// configuration
-(NSObject *)getConfig:(NSString *)keyString;
-(void)setConfig:(NSString *)keyString value:(NSObject *)valueObject;
-(void)loadDefaultConfiguration;

@end
