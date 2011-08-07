//
//  Course.m
//  ECaddy
//
//  Created by RKing on 6/4/11.
//  Copyright (c) 2011 RPKing. All rights reserved.
//

#import "Course.h"


@implementation Course
@dynamic phone;
@dynamic website;
@dynamic womenpars;
@dynamic woeid;
@dynamic numholes;
@dynamic coursename;
@dynamic menpars;
@dynamic favorite;
@dynamic pending;
@dynamic scorecards;
@dynamic teeCoords;
@dynamic greenCoords;

- (void)addScorecardsObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"scorecards"] addObject:value];
    [self didChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeScorecardsObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"scorecards"] removeObject:value];
    [self didChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addScorecards:(NSSet *)value {    
    [self willChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"scorecards"] unionSet:value];
    [self didChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeScorecards:(NSSet *)value {
    [self willChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"scorecards"] minusSet:value];
    [self didChangeValueForKey:@"scorecards" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
