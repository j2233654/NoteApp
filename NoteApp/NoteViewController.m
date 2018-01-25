//
//  NoteViewController.m
//  NoteApp
//
//  Created by 鍾哲允 on 2017/12/14.
//  Copyright © 2017年 Jimmy. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate/*, UITextViewDelegate*/>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic) BOOL isNewImage;

@property (nonatomic) NSLayoutConstraint *ratio;

@end

@implementation NoteViewController

- (IBAction)camera:(id)sender {
    //設定隱私權info.plist
    //add NSPhotoLibararyUsageDescription in the info.plist, iOS 10
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
     pickerController.delegate = self;
    //設定存取方式有基本三種，Camera:使用相機，PhotoLibrary:手機內的所有照片，SavedPhotoAlbum:相機膠卷
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
   
    [self presentViewController:pickerController animated:YES completion:nil]; 
}

- (IBAction)done:(id)sender {
    
    //把畫面的狀態，存回物件中
    self.note.text = self.textView.text;
    
    //save image -------------------------------------------------------------------------------------
    if(self.isNewImage){
        //xxxx.jpgs
        self.note.imageName = [NSString stringWithFormat:@"%@.jpg", self.note.noteID];
        //home + Documents
        NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        //圖片放在Documents下，路徑 = Documents/xxxx.jpg
        NSString *imagePath = [docPath stringByAppendingPathComponent:self.note.imageName];
        //轉成jpg格式
        NSData *data = UIImageJPEGRepresentation(self.imageView.image, 1);
        //寫到檔案的指定路徑
        [data writeToFile:imagePath atomically:YES];
    }
    //-------------------------------------------------------------------------------------
    //TODO: ListViewController: didFinishUpdateNote: self.note
    //呼叫ListViewController的didFinishUpdateNote方法，達到通知的目的
    [self.delegate didFinishUpdateNote:self.note];
    //id可以是任何物件，但是這個物件一定要有didFinishUpdateNote方法
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteUpdated" object:nil userInfo:@{@"note":self.note}];
    
    [self.navigationController popViewControllerAnimated:YES];  //跳出目前視圖
}

/*點擊鍵盤Return後會收起鍵盤，需實做UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.text = self.note.text;
    self.imageView.image = [self.note image];
    
    
    
    self.imageView.layer.borderWidth = 10;
    self.imageView.layer.borderColor = [UIColor blueColor].CGColor;
    self.imageView.layer.cornerRadius = 10;
    //self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.imageView.layer.shadowOpacity = 0.8;
    self.imageView.layer.shadowOffset = CGSizeMake(10, 10);
    
    // 程式關閉prefer large titles
    if( @available (iOS 11.0,*)){
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    //Intrinsic Content Size (回傳 -1 表示無法決定)
    NSLog(@"toolbar%@",NSStringFromCGSize(self.toolBar.intrinsicContentSize));
    NSLog(@"imageView%@",NSStringFromCGSize(self.imageView.intrinsicContentSize));
    
    //高度是寬度的0.75倍(可由StoryBoard Aspect Ratio設定)
    NSLayoutConstraint *ratio = [self.imageView.heightAnchor constraintEqualToAnchor:self.imageView.widthAnchor multiplier:0.75];   //1個條件
    self.ratio = ratio;     //放到property上，因為要跨方法
    //hR才要4:3
    if(self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular){
        ratio.active = YES;
    }
    /*
    //Visual Format Example (toolbar左右與super view間距零)
    NSArray *htoolbars = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:0 metrics:0 views:@{@"toolbar":self.toolBar}];
    [NSLayoutConstraint activateConstraints:htoolbars];
     */
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    //hC    //橫向 -> 4:3拿掉
    if(newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact){
        self.ratio.active = NO;
    }else{
        //其他，4:3要在
        self.ratio.active = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //取得使用者選取的照片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //放在imageView上
    self.imageView.image = image;
    self.isNewImage = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
