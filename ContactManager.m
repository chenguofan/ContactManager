//
//  ContactManager.m
//  ContactTest
//
//  Created by suhengxian on 2020/6/18.
//  Copyright © 2020 suhengxian. All rights reserved.
//

#import "ContactManager.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>

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

-(void)getTelWithName:(NSString *)name completeblock:(void(^)(ContactModel *model))completeBlock{
    NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                           CNContactPhoneNumbersKey];
    
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    
    [self.store enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
        
        NSString *fulName = [NSString stringWithFormat:@"%@%@%@",contact.familyName,contact.middleName,contact.givenName];
        
        if ([fulName isEqualToString:name]) {
            
            ContactModel *contactModel = [[ContactModel alloc] init];
            contactModel.name = fulName;
            contactModel.nickname = contact.nickname;
            contactModel.namePrefix = contactModel.namePrefix;
            contactModel.nameSuffix = contactModel.nameSuffix;
            
            NSMutableArray *telNumbers = [[NSMutableArray alloc] init];
            if (contact.phoneNumbers.count>0) {
                for (CNLabeledValue *cnLabe in contact.phoneNumbers) {
                    
                    CNPhoneNumber *cnNumber = cnLabe.value;
                    NSString *telPhoneNumber = cnNumber.stringValue;
                    [telNumbers addObject:telPhoneNumber];
                    
                }
            }
            
            contactModel.phoneNumbers = telNumbers;
            *stop = YES;
            
            if (completeBlock) {
                completeBlock(contactModel);
            }
        }
    }];
}

//模糊查找电话
-(void)getTelWithSubTel:(NSString *)subTel completeBlock:(void(^)(NSArray <ContactModel *>*contactModels))completeBlock{
    
    NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                           CNContactPhoneNumbersKey];
    
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    NSMutableArray *arrM = [NSMutableArray array];
    
    [self.store enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
        
        NSString *fulName = [NSString stringWithFormat:@"%@%@%@",contact.familyName,contact.middleName,contact.givenName];
        
//        if ([fulName isEqualToString:name]) {
            
            ContactModel *contactModel = [[ContactModel alloc] init];
            contactModel.name = fulName;
            contactModel.nickname = contact.nickname;
            contactModel.namePrefix = contactModel.namePrefix;
            contactModel.nameSuffix = contactModel.nameSuffix;
            
            NSMutableArray *telNumbers = [[NSMutableArray alloc] init];
            if (contact.phoneNumbers.count>0) {
                for (CNLabeledValue *cnLabe in contact.phoneNumbers) {
                    
                    CNPhoneNumber *cnNumber = cnLabe.value;
                    NSString *telPhoneNumber = cnNumber.stringValue;
                  
                    if ([telPhoneNumber containsString:subTel]) {
                        [telNumbers addObject:telPhoneNumber];
                        contactModel.phoneNumbers = telNumbers;
                        [arrM addObject:contactModel];
                    }
                }
            }
    }];
    
    if (completeBlock) {
        completeBlock(arrM);
    }
}

-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
}

@end
