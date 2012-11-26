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
  CCLOG(@"*** starting init gemgem framework %@ ***", GEMGEM_VERSION);

  if ( self = [super init] ) {
    _ggConfig = [[NSMutableDictionary alloc] init];
    _thisCCLayer = _layer;

    /*
    CCLOG(@"_ggConfig count(before):%d", [_ggConfig count]);
    [_ggConfig setObject:[NSNumber numberWithFloat:0.9f] forKey:@"GemGemVersion"];
    CCLOG(@"_ggConfig count(after):%d", [_ggConfig count]);
    */
    
    [self loadDefaultConfiguration];
    _thisStatus = ggStatusINIT;
  } else {
    CCLOG(@"init failed : crash");
    exit(EXIT_FAILURE);
  }
  
  return self;
}
-(ggStatus) getStatus {
  /*
  if (_thisStatus == ggStatusINIT) {
    CCLOG(@"ggStatus:INIT");
  } else if (_thisStatus == ggStatusReadyToTouch) {
    CCLOG(@"ggStatus:ReadyToTouch");
  } else if (_thisStatus == ggStatusInAnimation) {
    CCLOG(@"ggStatus:InAnimation");
  }
  */
  return _thisStatus;
}

-(void)loadDefaultConfiguration {
  [self setConfig:@"GemGemGameType" value:[NSNumber numberWithInt:1]];
  
  [self setConfig:@"GemTypeCount" value:[NSNumber numberWithInt:4]];
  /*
  // TODO: Gem Class 재정의 할 수 있도록 할 것 
  [self setConfig:@"GemType_01" value:[[ggGem alloc] initAsTest:1]];
  [self setConfig:@"GemType_02" value:[[ggGem alloc] initAsTest:2]];
  [self setConfig:@"GemType_03" value:[[ggGem alloc] initAsTest:3]];
  [self setConfig:@"GemType_04" value:[[ggGem alloc] initAsTest:4]];
  */
  
  [self setConfig:@"GemBoard_width" value:[NSNumber numberWithInt:8]];
  [self setConfig:@"GemBoard_height" value:[NSNumber numberWithInt:8]];
  [self setConfig:@"GemBoard_unitPixel" value:[NSNumber numberWithInt:32]];
  [self setConfig:@"GemBoard_anchor_pos" value:[NSValue valueWithCGPoint:ccp(48, 64)] ];

}

-(void) setConfig:(NSString *)keyString value:(id)valueObject {
  //CCLOG(@"_ggConfig count(before):%d", [_ggConfig count]);
  [_ggConfig setObject:valueObject forKey:keyString];
  //CCLOG(@"_ggConfig count(after):%d", [_ggConfig count]);

  CCLOG(@"_ggConfig[%@]:%@", keyString, ([_ggConfig objectForKey:keyString] != nil) ? @"ok" : @"failed");
}

-(NSObject *) getConfig:(NSString *)keyString {
  NSObject *o = [_ggConfig objectForKey:keyString];
  if ( o == nil) {
    
    return nil;
  }
  return o;
}

-(void) __drawBoard {
  _board = [[NSMutableDictionary alloc] init];
  int _unitSize = [[_ggConfig objectForKey:@"GemBoard_unitPixel"] intValue];
  
  for (int h = 1; h <= [[_ggConfig objectForKey:@"GemBoard_height"] intValue]; h++) {
    for (int w = 1; w <= [[_ggConfig objectForKey:@"GemBoard_width"] intValue]; w++) {
      NSValue *_posNSValue = [NSValue valueWithCGPoint:(CGPointMake(w, h))];
      /*
       // add:
       [array addObject:[NSValue value:&p withObjCType:@encode(struct Point)]];
       
       // extract:
       struct Point p;
       [[array objectAtIndex:i] getValue:&p];
       */
      ggBoardStruct bs;
      bs.isEmpty = YES;
      bs.Gem = nil;
      bs.gemType = 0;
      bs.position = ccpAdd([(NSValue*)[self getConfig:@"GemBoard_anchor_pos"] CGPointValue], ccp((w-1)*_unitSize, (h-1)*_unitSize));
      
      [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:_posNSValue];
    }
  }
}

-(int) __findBottom:(int)columnNumber {
  int gemBoard_height_from_config = [[_ggConfig objectForKey:@"GemBoard_height"] intValue];

  for (int h = gemBoard_height_from_config; h>=1 ; h--) {
    NSValue *pos = [NSValue valueWithCGPoint:CGPointMake(columnNumber, h)];
    NSValue *valueFrom_board = [_board objectForKey:pos];
    ggBoardStruct bs;
    [valueFrom_board getValue:&bs];
    if (bs.isEmpty == NO) {
      //CCLOG(@"(%d,%d) is NOT empty;return %d", columnNumber, h, h+1);
      return (h+1);
    }
    //CCLOG(@"Gem at pos(%d,%d) is %@", columnNumber, h, (bs.Gem == nil)?@"nil":@"CCSprite");
  }
  return 1; // default 
}

-(void) __dropGemsForFirstTime {
  ggStatus _lastStatus = _thisStatus;
  _thisStatus = ggStatusInAnimation;
  
  int gemBoard_height_from_config = [[_ggConfig objectForKey:@"GemBoard_height"] intValue];
  int _unitSize = [[_ggConfig objectForKey:@"GemBoard_unitPixel"] intValue];
  CGPoint boardAnchorPosition = [(NSValue*)[self getConfig:@"GemBoard_anchor_pos"] CGPointValue];
  //int lastActionTag = 0;
  NSMutableArray *actions = [[NSMutableArray alloc] init];
  
  for (int h = 1; h <= gemBoard_height_from_config; h++) {
    
    for (int w = 1; w <= [[_ggConfig objectForKey:@"GemBoard_width"] intValue]; w++ ) {
      int bottom = [self __findBottom:w];
      //if (bottom == gemBoard_height_from_config) continue; // 꼭데기 까지 차 있다면 다음줄로 ..
      // TODO: 초기화 과정에선 필요 없음 이 항목을 [self __dropGemAtColumn:(int)] 로 옮길때 같이 옮길 것
      
      //step1: gem 생성
      int gemType = rand() % 4 + 1; // 1,2,3,4
      //CCLOG(@"random GemType:%d", gemType);
      ggGem *g = [[ggGem alloc] initAsTest:gemType];
      
      //step2: 해당 _board 객체에 Gem 등록
      NSValue *pos = [NSValue valueWithCGPoint:(CGPointMake(w, bottom))];
      NSValue *valueFrom_board = [_board objectForKey:pos];
      ggBoardStruct bs;
      [valueFrom_board getValue:&bs];
      bs.Gem = g; // 등록(교체)
      bs.gemType = gemType;
      
      //TEST:
      //if (bs.isEmpty == NO) CCLOG(@"어 여기 뭔가 이상!");
      bs.isEmpty = NO;
      
      NSValue *obj = [NSValue value:&bs withObjCType:@encode(ggBoardStruct)]; // encode as NSValue
      //CCLOG(@"replace before count:%d", [_board count]);
      //CCLOG(@"Set/Update Gem on (NSMutableDictionary*)_board at pos(%d,%d)", w, bottom);
      [_board setObject:obj forKey:pos];
      //CCLOG(@"replace after count:%d", [_board count]);
      
      //step3: 애니메이션
      // pos(w,gemBoard_height_from_config) -> pos(w,bottom)=pos
      CCSprite *gemSprite = [g getCCSprite];
      gemSprite.position = ccpAdd(boardAnchorPosition, ccp((w-1)*_unitSize, (gemBoard_height_from_config+2)*_unitSize)); // starting point
      [_thisCCLayer addChild:gemSprite];
      
      float dropSpeed = 0.1f * (gemBoard_height_from_config + 2 - bottom);
      CGPoint targetPosition = ccpAdd(boardAnchorPosition, ccp((w-1)*_unitSize, (bottom)*_unitSize)); 
      
      CCAction *ani = [CCSequence actions:
                        [CCCallBlock actionWithBlock:^{
                          [gemSprite runAction:[CCMoveTo actionWithDuration:dropSpeed position:targetPosition]];
                        }],
                       [CCDelayTime actionWithDuration:0.02f],
                        //[CCCallBlock actionWithBlock:^{ localAnimationStatus = NO; }],
                        nil];
      [actions addObject:ani];
    }
  }
  // state flag 원래 대로 변경을 가장 마지막 action 으로 push 
  [actions addObject:[CCCallBlock actionWithBlock:^{ _thisStatus = _lastStatus; }]];
  
  //
  CCFiniteTimeAction *seq = nil;
  //int actionscount = 0;
	for (CCFiniteTimeAction *anAction in actions) {
    //CCLOG(@"actions Count:%d", ++actionscount);
		if (!seq) {
			seq = anAction;
		} else {
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}

  [_thisCCLayer runAction:seq];
}

-(void) run {
  // 이 method 가 실행 되는 위치가 custom setting 이후이므로 여기에서 전역 변수 전달
  
  //step 1 : 변수초기화
  srand(time(NULL));
  _board = [[NSMutableDictionary alloc] init];
  _thisGameType = [[_ggConfig objectForKey:@"GemGemGameType"] intValue];
  
  //step 2 : board 그리기
  [self __drawBoard];
  //step 3 : gem 낙하 width*height 갯수 만큼
  [self __dropGemsForFirstTime];
  CCLOG(@"*** Game Board init complete ***");
}

-(void) touchesEnded:(CGPoint)touchedLocation {

  for (NSValue *posAsNSValue in _board) {
    NSValue *valueFrom_board = [_board objectForKey:posAsNSValue];
    ggBoardStruct bs;
    [valueFrom_board getValue:&bs];
    CCSprite *s = [bs.Gem getCCSprite];
    if (CGRectContainsPoint(s.boundingBox, touchedLocation)) {
      CGPoint p = [posAsNSValue CGPointValue];
      CCLOG(@"touched Gem(%.f,%.f)", p.x, p.y);
      
      if ( _thisGameType == 1) {
        // BurstGem Style
        if ([self isTouchAvailable:touchedLocation]) {
          // go Burst !
          [self goGemBurst:posAsNSValue];
        }
      } else if (_thisGameType == 2) {
        // beJuweled Style
      }
      return;
    }
  }
}

-(BOOL) isTouchAvailable:(CGPoint)position {
  if (_thisStatus == ggStatusInAnimation) return NO;
  
  return YES;
}

//Game1 :
-(void) goGemBurst:(NSValue *)posInBoard {
  NSMutableArray *gems = [[NSMutableArray alloc] init];
  
  // seeding
  NSValue *valueFrom_board = [_board objectForKey:posInBoard];
  ggBoardStruct bs;
  [valueFrom_board getValue:&bs];
  int thisType = bs.gemType;

  // 돌리고 돌리고 돌리고
  [self GemContinuous:posInBoard gemType:thisType refArray:gems];
  
  // 결과물인 gems 의 카운트가 3개 이상?
  if ([gems count] >= 3) {
    [self gemBurst:gems];
    // TODO: 빈칸채우기
    // 다시 gem drop
    // 연쇄 판정 
  } else {
    CCLOG(@"모자라는데 잘못터치!");
    // 감점
  }
}

// Burst!
-(void) gemBurst:(NSMutableArray *)gems {
  for (NSValue *gemPos in gems) {
    //CGPoint pos = [gemPos CGPointValue];
    //CCLOG(@"butst:(%.f,%.f)", pos.x, pos.y);
    NSValue *valueFrom_board = [_board objectForKey:gemPos];
    ggBoardStruct bs;
    [valueFrom_board getValue:&bs];
    
    CCSprite *pong = [CCSprite spriteWithFile:@"pong.png"];
    
    //step1: 해당하는 Gem Sprite 를 날리고
    pong.position = [bs.Gem getCCSprite].position;
    [_thisCCLayer removeChild:[bs.Gem getCCSprite] cleanup:YES];
    //step2: 버스트 애니메이션
    
    //pong.position = [gemPos CGPointValue];
    [_thisCCLayer addChild:pong];
    id ac = [CCSequence actions:
             [CCRotateTo actionWithDuration:0.025f angle:-10],
             [CCRotateTo actionWithDuration:0.05f angle:10],
             [CCRotateTo actionWithDuration:0.05f angle:-10],
             [CCRotateTo actionWithDuration:0.05f angle:10],
             [CCDelayTime actionWithDuration:0.15f],
             [CCCallBlock actionWithBlock:^{ [_thisCCLayer removeChild:pong cleanup:YES]; }],
             nil];
    [pong runAction:ac];
    //step3: 구조체 reset
    bs.gemType = 0;
    bs.isEmpty = YES;
  }
}


// 재귀로 호출 될 함수
-(void) GemContinuous:(NSValue *)posAsNSValue gemType:(int)thisType refArray:(NSMutableArray* )gems {
  //CCLOG(@"continuous check :GemType[%d](%.f,%.f)", thisType, [posAsNSValue CGPointValue].x, [posAsNSValue CGPointValue].y);

  if (![gems containsObject:posAsNSValue] && [self isSameGem:thisType withPos:posAsNSValue]) {
    // 배열에 추가
    [gems addObject:posAsNSValue];
    
    CGPoint _posSeed = [posAsNSValue CGPointValue];
    NSValue *_pos;
    // 북쪽호출
    if (_posSeed.y != [[_ggConfig objectForKey:@"GemBoard_height"] intValue]) {
      _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x, _posSeed.y + 1)];
      [self GemContinuous:_pos gemType:thisType refArray:gems];
    }
    // 남쪽
    if (_posSeed.y != 1) {
    _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x, _posSeed.y - 1)];
    [self GemContinuous:_pos gemType:thisType refArray:gems];
    }
    // 동
    if (_posSeed.x != [[_ggConfig objectForKey:@"GemBoard_width"] intValue]) {
    _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x + 1, _posSeed.y)];
    [self GemContinuous:_pos gemType:thisType refArray:gems];
    }
    // 서
    if (_posSeed.x != 1) {
    _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x - 1, _posSeed.y)];
    [self GemContinuous:_pos gemType:thisType refArray:gems];
    }
  }
}

-(BOOL) isSameGem:(int)thisType withPos:(NSValue *)posAsNSValue {
  NSValue *valueFrom_board = [_board objectForKey:posAsNSValue];
  ggBoardStruct bs;
  [valueFrom_board getValue:&bs];
  //CCLOG(@"isSameGem: thisGem[%d] vs SeedGem[%d]", bs.gemType, thisType);
  if (bs.gemType == thisType) {
    return YES;
  } else {
    return NO;
  }
}

@end