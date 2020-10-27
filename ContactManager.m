//
//  ContactManager.m
//  ContactTest
//
//  Created by suhengxian on 2020/6/18.
//  Copyright © 2020 suhengxian. All rights reserved.
//

#import "ContactManager.h"
#import <Contacts/Contacts.h>
#import "NSString+Add.h"

@interface ContactManager ()
@property (nonatomic, strong) CNContactStore *store;

@end

static ContactManager *_manager = nil;

@implementation ContactManager

-(instancetype)init{
    if (self=[super init]) {
        _store = [CNContactStore new];
    }
    return self;
}

+(instancetype)manager{
    static ContactManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[ContactManager alloc] init];
    });
    return _manager;
}

-(CNAuthorizationStatus)getContactStatus{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    return status;
}

-(void)requestContactStatusWithCompletionHandler:(void(^)(BOOL granted,CNAuthorizationStatus status))handler{
    [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            NSLog(@"contact error:%@",error);
        }
        
        CNAuthorizationStatus status = [self getContactStatus];
        if (handler) {
            handler(granted,status);
        }
        
    }];
    
}

-(void)getTelWithName:(NSString *)name completeblock:(void(^)(NSArray <ContactModel *> *contactModels))completeBlock{
    
    NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                           CNContactPhoneNumbersKey];
    
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    NSMutableArray *arrM = [NSMutableArray array];
    
    [self.store enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact *contact, BOOL *stop)
    {
        //全名比较
            NSString *fulName = [NSString stringWithFormat:@"%@%@%@",contact.familyName,contact.middleName,contact.givenName];
            NSString *pinyin_fullName = [[NSString translateChineseToPinYin:fulName] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *pinyin_name = [[NSString translateChineseToPinYin:name]stringByReplacingOccurrencesOfString:@" " withString:@""];
              
        NSLog(@"pinyin_fullName == %@",pinyin_fullName);
        NSLog(@"pinyin_name == %@",pinyin_name);
        
        float likePercent = [NSString likePercent:pinyin_fullName OrString:pinyin_name];
        NSLog(@"likePercent == %f",likePercent);
        
        if ([pinyin_fullName isEqualToString:pinyin_name]) {
            ContactModel *contactModel = [[ContactModel alloc] initWithContact:contact];
            NSMutableArray *telNumbers = [[NSMutableArray alloc] init];
            if (contact.phoneNumbers.count>0) {
                for (CNLabeledValue *cnLabe in contact.phoneNumbers) {
                    
                    CNPhoneNumber *cnNumber = cnLabe.value;
                    NSString *telPhoneNumber = [cnNumber.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                    telPhoneNumber = [telPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    telPhoneNumber = [telPhoneNumber stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    [telNumbers addObject:telPhoneNumber];
                }
            }
            contactModel.phoneNumbers = telNumbers;
            [arrM addObject:contactModel];
            
        }else{
            if (likePercent > 85)
            {
                ContactModel *contactModel = [[ContactModel alloc] initWithContact:contact];
                NSMutableArray *telNumbers = [[NSMutableArray alloc] init];
                if (contact.phoneNumbers.count>0)
                {
                    for (CNLabeledValue *cnLabe in contact.phoneNumbers)
                    {
                
                        CNPhoneNumber *cnNumber = cnLabe.value;
                        NSString *telPhoneNumber = [cnNumber.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                        telPhoneNumber = [telPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        telPhoneNumber = [telPhoneNumber stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                        [telNumbers addObject:telPhoneNumber];
                    }
                }
                contactModel.phoneNumbers = telNumbers;
                [arrM addObject:contactModel];
            }
        }
        
    }];
    
    NSLog(@"arrM == %@",arrM);
    
    if (completeBlock){
        completeBlock(arrM);
    }
    
}

//模糊查找电话
-(void)getTelWithSubTel:(NSString *)subTel completeBlock:(void(^)(NSArray <ContactModel *>*contactModels))completeBlock{
    
    NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                           CNContactPhoneNumbersKey];
    
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    NSMutableArray *arrM = [NSMutableArray array];
    
    [self.store enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
        
        NSString *fulName = [NSString stringWithFormat:@"%@%@%@",contact.familyName,contact.middleName,contact.givenName];
        
        ContactModel *contactModel = [[ContactModel alloc] initWithContact:contact];
        
            NSMutableArray *telNumbers = [[NSMutableArray alloc] init];
            if (contact.phoneNumbers.count>0) {
                for (CNLabeledValue *cnLabe in contact.phoneNumbers) {
                    CNPhoneNumber *cnNumber = cnLabe.value;
                    NSString *telPhoneNumber = [cnNumber.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                    telPhoneNumber = [telPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    telPhoneNumber = [telPhoneNumber stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    
                    if ([telPhoneNumber containsString:subTel]) {
                        [telNumbers addObject:telPhoneNumber];
                        contactModel.phoneNumbers = telNumbers;
                        [arrM addObject:contactModel];
                    }
                }
            }
    }];
    
    NSLog(@"arrM == %@",arrM);
    
    if (completeBlock) {
        completeBlock(arrM);
    }
}

-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
}

@end
