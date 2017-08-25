//
//  FMDatabasePoolAdditions.h
//  Balance
//

#import "FMDB.h"

@interface FMDatabasePool (Additions)

- (int)intForQuery:(NSString*)query, ...;
- (long)longForQuery:(NSString*)query, ...; 
- (BOOL)boolForQuery:(NSString*)query, ...;
- (double)doubleForQuery:(NSString*)query, ...;
- (NSString*)stringForQuery:(NSString*)query, ...; 
- (NSData*)dataForQuery:(NSString*)query, ...;
- (NSDate*)dateForQuery:(NSString*)query, ...;

- (BOOL)tableExists:(NSString*)tableName;
- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName;

@end
