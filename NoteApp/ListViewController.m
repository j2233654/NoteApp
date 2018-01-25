//
//  ListViewController.m
//  NoteApp
//
//  Created by 鍾哲允 on 2017/12/14.
//  Copyright © 2017年 Jimmy. All rights reserved.
//

#import "ListViewController.h"
#import "Note.h"
#import "NoteCell.h"
#import "NoteViewController.h"
#import "CoreDataHelper.h"

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, NoteViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSMutableArray<Note*> *data; // <Note> 指定只可放Note的物件
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@end

@implementation ListViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        //以下兩種寫法皆可
        //self.data = [[NSMutableArray alloc] init];
        //self.data = [NSMutableArray array];
        
/*假資料，重開模擬器會消失
            for(int i=0; i<10 ; i++){
            //記得要noteID先實作
            Note *note = [[Note alloc] init];
            note.text = [NSString stringWithFormat:@"Note %d",i];
            [self.data addObject:note];
*/
 /*Notification
            註冊對NoteUpdate事件有興趣，發生時呼叫*finishUpdate方法
            //[[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(finishUpdate:) name:@"NoteUpdated" object:nil];
        }
*/

/*
// Archiving：查詢
        [self loadFromFile];
*/
        
// Core Data : 查詢
         [self queryFromCoreData];
    }
    return self;
}

#pragma mark - Archiving
// 新增(saveToFile)、刪除(saveToFile)、修改(saveToFile)、查詢(loadFromFile)時需要執行相對應的方法 (新刪改查)
-(void)saveToFile{
    
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"notes.archive"];
    
    [NSKeyedArchiver archiveRootObject:self.data toFile:filePath];
}

-(void)loadFromFile{
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"notes.archive"];
    
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    if (data){
        self.data = [NSMutableArray arrayWithArray:data];
    }else{
        self.data = [NSMutableArray array];
    }
}

#pragma mark - Core Date
-(void) queryFromCoreData{
    CoreDataHelper *coreData = [CoreDataHelper sharedInstance];
    
    //利用NSFetchRequest進行查詢
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Note" ];
    //NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"Note"]; // 跟上面一行相同
    
    NSError *error = nil;
    NSArray *results = [coreData.managedObjectContext executeFetchRequest:request error:&error];
    if(error){
        NSLog(@"error while fetching Notes %@",error);
        self.data = [NSMutableArray array];
    }else{
        self.data = [NSMutableArray arrayWithArray:results];
    }
}

-(void)saveToCoreData{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSManagedObjectContext *context = helper.managedObjectContext;
    
    NSError *error = nil;
    [context save:&error];
    
    if ( error ){
        NSLog(@"error while saving %@",error);
    }
}

#pragma mark -
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //取消訂閱通知，通常在要卸載記憶體(dealloc)時
}

-(void)finishUpdate:(NSNotification*)notifiacation{
    
    Note *note = notifiacation.userInfo[@"note"];
    //找到在data中的位置
    NSUInteger index = [self.data indexOfObject:note];
    //產生畫面位置
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //重新載入該位置的cell，以達到更新改筆的目的
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self; // 也可以由storyboard建立cell dataSource跟controller的連結(用拉的)
    self.tableView.delegate = self;
    
    //self.tableView.estimatedRowHeight = 50;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"List"; //亦可於Storyboard的Navigation Item內設定
    
    // 程式啟用prefer large titles, 亦可由StoryBoard點選
    if( @available (iOS 11.0,*)){
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
}

- (IBAction)refresh:(id)sender {
    UIBarButtonItem *item = sender;
    UIActivityIndicatorView *indic = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indic.translatesAutoresizingMaskIntoConstraints = NO;   //iOS11之後，Custom Item可設定AutoLayout，關閉後動畫可正常。
    item.customView = indic; //取代原本的圖示，改用customView
    [indic startAnimating]; //開始旋轉
    
    //GCD只負責把block中的程式丟給其他執行緒執行，但執行順序與何時執行不曉得
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //block中的程式，會在背景queue中執行
        [NSThread sleepForTimeInterval:3]; //暫停目前的程式3秒，模擬網路作業
        
        //把程式丟回thread 1執行，通常是畫面更新
        dispatch_async(dispatch_get_main_queue(), ^{
           item.customView = nil; //清除customVIew，變回原本的refresh圖案
        });
    });
    
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

//-----------------------------------------------------------------------
#pragma mark - toolBarButtonItem
- (IBAction)edit:(id)sender {
    //self.tableView.editing = !self.tableView.editing;
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (IBAction)addNote:(id)sender {
/* Core Data 不可用alloc init，所以還需要重新產生noteID
    //Note *note = [[Note alloc] init];
*/
    
    //Core Data : 新增
    CoreDataHelper *coreData = [CoreDataHelper sharedInstance];
    //利用NSEntityDescription產生新的Note
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:coreData.managedObjectContext];
    note.text = @"New Note";
    note.noteID = [[NSUUID UUID] UUIDString];
    [self.data insertObject:note atIndex:0];
    [self saveToCoreData];
    
    
/*
    // Archiving：新增
    [self saveToFile];
*/
    
    
    //設定新增的位置NSIndexPath
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //通知tableview新增一筆資料到畫面上
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//-----------------------------------------------------------------------
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

//每一筆長什麼樣子
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //產生一個預設樣式，一個文字，一張圖片
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noteCell" forIndexPath:indexPath];
    
    /*Customcell
    //根據indexPath位置取得array中相對應順序的Note物件
    Note *note = self.data[indexPath.row];
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customcell" forIndexPath:indexPath];
    cell.label.text = note.text;
    */
    
 
    //根據indexPath位置取得array中相對應順序的Note物件
    Note *note = self.data[indexPath.row];
    cell.textLabel.text = note.text;
    cell.imageView.image = [note thumbnailImage];
    cell.showsReorderControl = YES; //可直接在StoryBoard的cell內勾選
    //cell.accessoryView = [[UISwitch alloc] init];
    
    return cell;
}

//-----------------------------------------------------------------------

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        
        //CoreData : 刪除
        Note *note = self.data[indexPath.row]; //先取出物件
        [self.data removeObjectAtIndex:indexPath.row]; //移除data中的物件
        
        //利用ManageObjectContext刪除CoreData中的物件
        CoreDataHelper *coreData = [CoreDataHelper sharedInstance];
        NSManagedObjectContext *context = coreData.managedObjectContext;
        [context deleteObject:note];
        
        
        
        //刪除完後必須進行save
        [self saveToCoreData];
        
/*
        // Archiving：刪除
        [self saveToFile];
*/
        
        //通知tableView刪除哪一筆資料
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    Note *note = self.data [sourceIndexPath.row];
    //刪除原本位置
    [self.data removeObjectAtIndex:sourceIndexPath.row];
    //放到新的位置
    [self.data insertObject:note atIndex:destinationIndexPath.row];
    
}

//-----------------------------------------------------------------------
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //反向選取
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    //請StoryBoard產生一組畫面
    NoteViewController *noteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"noteViewController"];
     
    [self.navigationController pushViewController:noteVC animated:YES];     //push
    
     //[self showViewController:noteVC sender:self];     //show
     */
}

//-----------------------------------------------------------------------

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"note"]){
        NoteViewController *noteVC = segue.destinationViewController;
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        
        Note *note = self.data[indexPath.row];
        noteVC.note = note;
        noteVC.delegate = self;
    }
}

//給NoteViewController呼叫用的，用來通知已經更新
//可以更新該筆的cell，達到顯示正確的資料
-(void)didFinishUpdateNote:(Note*)note{
    
    //CoreData：修改
    [self saveToCoreData];
    
/*
    // Archiving：修改
    [self saveToFile];
*/
    
    //找到在data中的位置
    NSUInteger index = [self.data indexOfObject:note];
    //產生畫面位置
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //重新載入該位置的cell，以達到更新改筆的目的
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
