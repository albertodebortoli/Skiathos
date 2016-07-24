# ADBCoreDataStack

A minimalistic, thread safe and non-boilerplate version of Active Record on Core Data (WIP).

## General notes

In Core Data we usually call `performBlock:` on a context witha block that eventually will call `save:` on that context.
Databases are all about readings and writings and for this reason our APIs are in the form of `read:` and `write:`.

The stack used by this component is the one described [here](http://martiancraft.com/blog/2015/03/core-data-stack/) by Marcus Zarra.

```
                                Persistent Store Coordinator
                                               ^
                                               |
                       Private Context (NSPrivateQueueConcurrencyType)
                                               ^
                                               |
                           Main Context (NSMainQueueConcurrencyType)
             ^                                 ^                                  ^
             |                                 |                                  |
     Slave Contexts                    Slave Contexts                     Slave Contexts
(NSPrivateQueueConcurrencyType)   (NSPrivateQueueConcurrencyType)    (NSPrivateQueueConcurrencyType)
```

The basic design involves a few main components:

- PersistenceController
- DALService (Data Access Layer)
- CoreDataStack

Client can configure the CoreDataStack inheriting from it and providing a sharedInstance for ease of use (e.g. JustEatCoreDataStack).

An important difference from Magical Record is that the saves always go in one direction, from slaves down to the persistent store.
Magical Record allows you to create slaves that have the private context as parent and this causes the main context not to be updated or to be updated via notifications to merge the context.
The main context should be the source of truth and is tied to your UI, having a much simpler approach helps to create a system easier to reason about.

## Thread safery

All the accesses to the persistence layer should be done via the DALService and are guaranteed to be thread-safe.
It is highly suggested to enable the flag `-com.apple.CoreData.ConcurrencyDebug 1` in your project to make sure that the you don't misuse Core Data in terms of threading and concurrency (by accessing managed objects from different threads and similar errors).

We don't want to consider creating interfaces to hide the concept of `ManagedObjectContext`: it would open up the doors to threading issues in clients' code as developers should be responsible to check for the type of the calling thread at some level (that would be ignoring the benefits that Core Data gives to us).
Therefore, the design of JustPersistence forces us to make all the readings and writings via the `DALService` and the `ManagedObject` category methods are intended to always be explicit on the context (e.g. `createInContext:`).

Readings happen to the main context, while writings happen to the slave one and changes are always saved back to the persistence store asynchronously without blocking the main thread.

## Show me the code

Standard Core Data reading:

```
__block NSArray *results = nil;

NSManagedObjectContext *context = ...;
[context performBlockAndWait:^{

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(User)
                                                         inManagedObjectContext:context];
    [request setEntity:entityDescription];
    
    NSError *error;
    results = [context executeFetchRequest:request error:&error];
}];

return results;
```

Standard Core Data writing:

```
NSManagedObjectContext *context = ...;
    [context performBlockAndWait:^{

    User *user = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(User)
                                               inManagedObjectContext:context];
    user.firstname = @"John";
    user.lastname = @"Doe";

    NSError *error;
    [context save:&error];
    if (!error)
    {
        // continue to save down to the store
    }
}];

```

JustPersistence reading: 

```
[JustPersistence read:^(NSManagedObjectContext *context) {
    NSArray *allUsers = [User allInContext:context];
    NSLog(@"All users: %@", allUsers);
}];
```

JustPersistence writing:

```
[JustPersistence write:^(NSManagedObjectContext *context) {
    User *user = [User createInContext:context];
    user.firstname = @"John";
    user.lastname = @"Doe";
}];
```

## TO DO

- Tests
- Swift version
