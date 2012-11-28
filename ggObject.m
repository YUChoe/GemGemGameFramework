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
  [self setConfig:@"GemBoard_unitPixel" value:[NSNumber numberWithInt:40]];
  //[self setConfig:@"GemBoard_anchor_pos" value:[NSValue valueWithCGPoint:ccp(48, 180)] ];
  [self setConfig:@"GemBoard_anchor_pos" value:[NSValue valueWithCGPoint:ccp(20, 100)] ];
}

-(void) setConfig:(NSString *)keyString value:(id)valueObject {
  //CCLOG(@"_ggConfig count(before):%d", [_ggConfig count]);
  [_ggConfig setObject:valueObject forKey:keyString];
  //CCLOG(@"_ggConfig count(after):%d", [_ggConfig count]);

  //CCLOG(@"_ggConfig[%@]:%@", keyString, ([_ggConfig objectForKey:keyString] != nil) ? @"ok" : @"failed");
}

-(NSObject *) getConfig:(NSString *)keyString {
  NSObject *o = [_ggConfig objectForKey:keyString];
  if ( o == nil) {
    
    return nil;
  }
  return o;
}


-(int) getScore {
  return _gameScore;
}
-(void) setScore:(int)newScore {
  int margin = newScore - _gameScore;
  _gameScore = newScore;
  
  NSMutableDictionary *userInfoMDic = [[NSMutableDictionary alloc] init];
  
  [userInfoMDic setObject:[NSNumber numberWithInt:margin] forKey:@"margin"];
  [userInfoMDic setObject:[NSNumber numberWithInt:_gameScore] forKey:@"score"];
  [userInfoMDic setObject:[NSValue valueWithCGPoint:_lastEventTouchPoint] forKey:@"point"];
  
  NSDictionary *userInfoDic = [[userInfoMDic copy] autorelease];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GG_NOTIFICATION_SCORE_UPDATE object:self userInfo:userInfoDic];
  
}


-(void) __drawBoard {
  _board = [[NSMutableDictionary alloc] init];
  
  for (int h = 1; h <= ggConfig.BoardHeight; h++) {
    for (int w = 1; w <= ggConfig.BoardWidth ; w++) {
      NSValue *_posNSValue = [NSValue valueWithCGPoint:(CGPointMake(w, h))];

      ggBoardStruct bs;
      bs.isEmpty = YES;
      bs.Gem = nil;
      bs.gemType = 0;
      bs.position = ccpAdd([(NSValue*)[self getConfig:@"GemBoard_anchor_pos"] CGPointValue], ccp((w-1)*ggConfig.GemSizeBYPixel, (h-1)*ggConfig.GemSizeBYPixel));
      
      [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:_posNSValue];
    }
  }
}

-(int) __findBottom:(int)columnNumber {
  for (int h = ggConfig.BoardHeight; h>=1 ; h--) {
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
  
  NSMutableArray *actions = [[NSMutableArray alloc] init];
  
  for (int h = 1; h <= ggConfig.BoardHeight; h++) {
    for (int w = 1; w <= ggConfig.BoardWidth; w++ ) {
      int bottom = [self __findBottom:w];
      CCAction *ani = [self __gemDropAtColumn:w bottom:bottom];
      if (ani != nil) [actions addObject:ani];
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

  // config
  ggConfig.GameType            = [[_ggConfig objectForKey:@"GemGemGameType"]     intValue];
  ggConfig.GemSizeBYPixel      = [[_ggConfig objectForKey:@"GemBoard_unitPixel"] intValue];
  ggConfig.BoardHeight         = [[_ggConfig objectForKey:@"GemBoard_height"]    intValue];
  ggConfig.BoardWidth          = [[_ggConfig objectForKey:@"GemBoard_width"]     intValue];
  ggConfig.BoardAnchorPosition = [[_ggConfig objectForKey:@"GemBoard_anchor_pos"] CGPointValue];

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
      //CGPoint p = [posAsNSValue CGPointValue];
      //CCLOG(@"touched Gem(%.f,%.f)", p.x, p.y);
      
      if ( ggConfig.GameType == 1) {
        // BurstGem Style
        if ([self isTouchAvailable:touchedLocation]) {
          // go Burst !
          _lastEventTouchPoint = touchedLocation;
          [self goGemBurst:posAsNSValue];
        }
      } else if (ggConfig.GameType == 2) {
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
  if (thisType ==0) {
    CCLOG(@"게임 중에는 gravityJob 때문에 발생하지 않지만 빈칸?!");
    return;
  }
  // 돌리고 돌리고 돌리고
  [self GemContinuous:posInBoard gemType:thisType refArray:gems];
  
  // 결과물인 gems 의 카운트가 3개 이상?
  if ([gems count] >= 3) {
    [self gemBurst:gems];
    // TODO: 빈칸채우기
    NSMutableDictionary *blankColumns = [self __gravityJob:gems];
    // TEST: Score Update
    [self setScore: _gameScore + ([gems count] * 10)];
    
    // 다시 gem drop
    [self __fillBlank:blankColumns];
    // 연쇄 판정 
  } else {
    CCLOG(@"모자라는데 잘못터치!");
    // 감점
  }
}

-(void) __fillBlank:(NSMutableDictionary *)blankColumns {
  ggStatus _lastStatus = _thisStatus;
  _thisStatus = ggStatusInAnimation;

  NSMutableArray *actions = [[NSMutableArray alloc] init];
  [actions addObject:[CCDelayTime actionWithDuration:0.5f]]; //gravity 기다리는 시간 
  
  for (NSNumber *c in blankColumns) {
    NSMutableArray *points = [blankColumns objectForKey:c];
    
    //int bottom = [self __findBottom:[c intValue]];
    //CCLOG(@"채우기:col[%d]:%d번째부터 %d개", [c intValue], bottom, [points count]);
    
    for (int cnt = 1; cnt <= [points count]; cnt++) {
      int _btm = [self __findBottom:[c intValue]];
      CCAction *a = [self __gemDropAtColumn:[c intValue] bottom:_btm];
      if (a != nil) {
        [actions addObject:a];
        [actions addObject:[CCDelayTime actionWithDuration:0.05f]];
      }
    }
    
  }
  //CCLOG(@"action count:%d", [actions count]);
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

-(CCAction *) __gemDropAtColumn:(int)columnNumber bottom:(int)bottom {
  if (bottom == ggConfig.BoardHeight) return nil; // 꼭데기 까지 차 있다면 다음줄로 ..

  //step1: gem 생성
  int gemType = rand() % 4 + 1; // 1,2,3,4
                                //CCLOG(@"random GemType:%d", gemType);
  ggGem *g = [[ggGem alloc] initAsTest:gemType];
  
  //step2: 해당 _board 객체에 Gem 등록
  NSValue *pos = [NSValue valueWithCGPoint:(CGPointMake(columnNumber, bottom))];
  NSValue *valueFrom_board = [_board objectForKey:pos];
  ggBoardStruct bs;
  [valueFrom_board getValue:&bs];
  bs.Gem = g; // 등록(교체)
  bs.gemType = gemType;
  
  //TEST:
  //if (bs.isEmpty == NO) CCLOG(@"어 여기 뭔가 이상!");
  bs.isEmpty = NO;
  bs.position = ccpAdd(ggConfig.BoardAnchorPosition, ccp((columnNumber - 1) * ggConfig.GemSizeBYPixel, (bottom)*ggConfig.GemSizeBYPixel));
  
  NSValue *obj = [NSValue value:&bs withObjCType:@encode(ggBoardStruct)]; // encode as NSValue
                                                                          //CCLOG(@"replace before count:%d", [_board count]);
                                                                          //CCLOG(@"Set/Update Gem on (NSMutableDictionary*)_board at pos(%d,%d)", w, bottom);
  [_board setObject:obj forKey:pos];
  //CCLOG(@"replace after count:%d", [_board count]);
  
  //step3: 애니메이션
  // pos(w,gemBoard_height_from_config) -> pos(w,bottom)=pos
  CCSprite *gemSprite = [g getCCSprite];
  gemSprite.position = ccpAdd(ggConfig.BoardAnchorPosition,
                              ccp((columnNumber - 1)*ggConfig.GemSizeBYPixel, (ggConfig.BoardHeight+2)*ggConfig.GemSizeBYPixel)); // starting point
  [_thisCCLayer addChild:gemSprite];
  
  float dropSpeed = 0.1f * (ggConfig.BoardHeight + 2 - bottom);
  CGPoint targetPosition = ccpAdd(ggConfig.BoardAnchorPosition, ccp((columnNumber - 1)*ggConfig.GemSizeBYPixel, (bottom)*ggConfig.GemSizeBYPixel));
  
  CCAction *ani = [CCSequence actions:
                   [CCCallBlock actionWithBlock:^{ [gemSprite runAction:[CCMoveTo actionWithDuration:dropSpeed position:targetPosition]]; }],
                   [CCDelayTime actionWithDuration:0.02f],
                   //[CCCallBlock actionWithBlock:^{ localAnimationStatus = NO; }],
                   nil];
  return ani;
  
}

// gravity job
-(NSMutableDictionary *) __gravityJob:(NSMutableArray *)gems {
  NSMutableDictionary *colDic = [[NSMutableDictionary alloc] init]; // key: 칼럼#, value: pos배열
  //CCLOG(@"gems count:%d", [gems count]);
  
  for (NSValue *gemPos in gems) {
    CGPoint p = [gemPos CGPointValue];
    NSNumber *xx = [NSNumber numberWithFloat: p.x];
    if ([colDic objectForKey:xx] == nil) {
      NSMutableArray *points = [[NSMutableArray alloc] init];
      [points addObject:gemPos];
      [colDic setObject:points forKey:xx];
    } else {
      // 이미 있는 칼럼
      NSMutableArray *points = [colDic objectForKey:xx];
      [points addObject:gemPos];
      [colDic setObject:points forKey:xx];
    }
  }
  //CCLOG(@"columns count:%d", [colDic count]);
  for (NSNumber *c in colDic) {
    //NSMutableArray *points = [colDic objectForKey:c];
    //CCLOG(@"채우기:col[%d]:%d개", [c intValue], [points count]);

    for (int h = 1; h <= ggConfig.BoardHeight; h++) {
      //CCLOG(@"%d회차 중력 작동", h);
      
      NSValue *blankBoardPos = nil;
      NSValue *fallingGemPos = nil;
      
      for (int hh = 1; hh <= ggConfig.BoardHeight; hh++) {
        NSValue *posAsNSValue = [NSValue valueWithCGPoint:CGPointMake([c intValue], hh)];
        NSValue *valueFrom_board = [_board objectForKey:posAsNSValue];
        ggBoardStruct bs;
        [valueFrom_board getValue:&bs];
        if (bs.isEmpty == YES && blankBoardPos == nil) {
          //CCLOG(@"아래로부터 거슬러 올라가면서 최초의 빈칸:%d", hh);
          blankBoardPos = posAsNSValue;
        } else if (bs.isEmpty == NO && fallingGemPos == nil && blankBoardPos != nil) {
          //CCLOG(@"아래로부터 거슬러 올라가면서 최초의 Gem:%d", hh);
          fallingGemPos = posAsNSValue;
          break;
        }
      } // of for hh loop
      
      // _board 안의 gem@fallingGemPos 속성 변경
      
      if (blankBoardPos != nil && fallingGemPos != nil) {
        //CCLOG(@"Gem is falling down");
        
        NSValue *valueFrom_board = [_board objectForKey:fallingGemPos];
        ggBoardStruct bs;
        [valueFrom_board getValue:&bs];
        
        CCSprite *gemSpr = [bs.Gem getCCSprite];
        
        NSValue *targetValueFrom_board = [_board objectForKey:blankBoardPos];
        ggBoardStruct bs_blank;
        [targetValueFrom_board getValue:&bs_blank];
        
        bs_blank.Gem = bs.Gem;
        bs_blank.gemType = bs.gemType;
        //bs_blank.position = bs.position;
        bs_blank.isEmpty = NO;
        [_board setObject:[NSValue value:&bs_blank withObjCType:@encode(ggBoardStruct)] forKey:blankBoardPos];
        
        bs.Gem = nil;
        bs.gemType = 0;
        bs.isEmpty = YES;
        [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:fallingGemPos];
        
        // fallingGemPos -> blankBoardPos 애니메이션
        [gemSpr runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.2f],
                           [CCMoveTo actionWithDuration:(0.2f) position:bs_blank.position],
                           nil]
         ];
        
        blankBoardPos = nil;
        fallingGemPos = nil;
        
      } else {
        //CCLOG(@"nil nil");
      }
      
      //
      
    } // of for h
  } // of for columns
  
  return colDic;
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
    [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:gemPos];
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
    if (_posSeed.y != ggConfig.BoardHeight) {
      _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x, _posSeed.y + 1)];
      [self GemContinuous:_pos gemType:thisType refArray:gems];
    }
    // 남쪽
    if (_posSeed.y != 1) {
    _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x, _posSeed.y - 1)];
    [self GemContinuous:_pos gemType:thisType refArray:gems];
    }
    // 동
    if (_posSeed.x != ggConfig.BoardWidth) {
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