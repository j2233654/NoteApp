//
//  ListViewController.h
//  NoteApp
//
//  Created by 鍾哲允 on 2017/12/14.
//  Copyright © 2017年 Jimmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface ListViewController : UIViewController

-(void)didFinishUpdateNote: (Note*) note;
@end
