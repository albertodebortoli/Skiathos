# Skiathos

A minimalistic, thread-safe, non-boilerplate and super easy to use version of Active Record on Core Data.
Simply all you need for doing Core Data. Objective-C flavour.

[Swift version](https://github.com/albertodebortoli/Skopelos)

## General notes

This component aims to have an extremely easy interface to introduce Core Data into your app with almost zero effort.

The design introduced here involves a few main components:

- CoreDataStack
- AppStateReactor
- DALService (Data Access Layer)

### CoreDataStack

If you have experience with Core Data, you might know that creating a stack is an annoying process full of pitfalls.
This component is responsible for the creation of the stack (in terms of chain of managed object contexts) using the design described [here](http://martiancraft.com/blog/2015/03/core-data-stack/) by Marcus Zarra.

```
      Managed Object Model <------ Persistent Store Coordinator ------> Persistent Store
                                                ^
                                                |
                           Root Context (NSPrivateQueueConcurrencyType)
                                                ^
                                                |
              ------------> Main Context (NSMainQueueConcurrencyType) <-------------
              |                                 ^                                  |
              |                                 |                                  |
        Slave Context                     Slave Context                      Slave Context
(NSPrivateQueueConcurrencyType)   (NSPrivateQueueConcurrencyType)    (NSPrivateQueueConcurrencyType)
```

An important difference from Magical Record, or other third-party libraries, is that the saves always go in one direction, from slaves down (or up?) to the persistent store.
Other components allows you to create slaves that have the private context as parent and this causes the main context not to be updated or to be updated via notifications to merge the context.
The main context should be the source of truth and it is tied the UI: having a much simpler approach helps to create a system easier to reason about.

### AppStateReactor

You should ignore this one. It sits in the CoreDataStack and takes care of saving the inflight changes back to disk if the app goes to background, loses focus or is about to be terminated. It's a silent friend who takes care of us.


### DALService (Data Access Layer) / Skiathos

If you have experience with Core Data, you might also know that most of the operations are repetitive and that we usually call `performBlock:`/`performBlockAndWait:` on a context providing a block that eventually will call `save:` on that context as last statement.
Databases are all about readings and writings and for this reason our APIs are in the form of `read:` and `write:`: 2 protocols providing a CQRS (Command and Query Responsibility Segregation) approach.
Read blocks will be executed on the main context (as it's considered to be the single source of truth). Write blocks are executed on a slave context which is saved synchronously at the end; changes are eventually saved asynchronously back to the persistent store without blocking the main thread. 
The method `write:completion:` calls the completion handler when the changes are saved back to the persistent store.  

In other words, writings are always consistent in the main managed object context and eventual consistent in the persistent store.
Data are always available in the main managed object context.

`Skiathos` is just a subclass of `DALService`, to give a nice name to the component. 


## How to use

Import `Skiathos.h`.

To use this component, you could create a property of type `Skiathos` and instantiate it like so:

```objc
self.skiathos = [Skiathos setupInMemoryStackWithDataModelFileName:@"<#DataModelFileName>"];
```
or
```objc
self.skiathos = [Skiathos setupSqliteStackWithDataModelFileName:@"<#DataModelFileName>"];
```

You could then pass around the skiathos in other parts of the app via dependency injection.
It has to be said that it's perfectly acceptable to use a singleton for the Core Data stack. Also, allocating instances over and over is expensive. Genrally speaking, we don't like singletons. They are not testable by nature, clients don't have control over the lifecycle of the object and they break some principles. For these reasons, the library comes free of singletons.

There are 2 reasons why you should inherit from `Skiathos`:

- to create a shared instance for global access
- to override `- (void)handleError:(NSError *)error;` to perform specific actions when an error is encountered and this method is called 

To create a singleton, you should inherit from Skiathos like so:

### Singleton

```objc
@interface SkiathosClient : Skiathos

+ (SkiathosClient *)sharedInstance;

@end

static SkiathosClient *sharedInstance = nil;

@implementation SkiathosClient

+ (SkiathosClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self setupSqliteStackWithDataModelFileName:@"<#DataModelFileName>"];
    });

    return sharedInstance;
}

- (void)handleError:(NSError *)error
{
    // clients should do the right thing here
    NSLog(@"%@", error.description);
}

@end
```

### Readings and writings

Speaking of readings and writings, let's do now a comparison between some standard Core Data code and code written with Skiathos.

Standard Core Data reading:

```objc
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

```objc
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
        // continue to save back to the store
    }
}];

```

Skiathos reading: 

```objc
[[SkiathosClient sharedInstance] read:^(NSManagedObjectContext *context) {
    NSArray *allUsers = [User allInContext:context];
    NSLog(@"All users: %@", allUsers);
}];
```

Skiathos writing:

```objc
[[SkiathosClient sharedInstance] write:^(NSManagedObjectContext *context) {
    User *user = [User createInContext:context];
    user.firstname = @"John";
    user.lastname = @"Doe";
}];

[[SkiathosClient sharedInstance] write:^(NSManagedObjectContext *context) {
    User *user = [User createInContext:context];
    user.firstname = @"John";
    user.lastname = @"Doe";
} completion:^(NSError *error) {
    // changes are saved to the persistent store
}];
```

Skiathos also supports dot notation and chaining:

```objc
__block User *user = nil;

[SkiathosClient sharedInstance].write(^(NSManagedObjectContext *context) {

    user = [User createInContext:context];
    user.firstname = @"John";
    user.lastname = @"Doe";

}).write(^(NSManagedObjectContext *context) {

    User *userInContext = [user inContext:context];
    [userInContext deleteInContext:context];
    
}).read(^(NSManagedObjectContext *context) {

    NSArray *users = [User allInContext:context];

});
```

The `NSManagedObject` category provides CRUD methods always explicit on the context. The context passed as parameter should be the one received in the read or write block. You should always use these methods from within read/write blocks. Main methods are:

```objc
+ (instancetype)SK_createInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)SK_numberOfEntitiesInContext:(NSManagedObjectContext *)context;
- (void)SK_deleteInContext:(NSManagedObjectContext *)context;
+ (void)SK_deleteAllInContext:(NSManagedObjectContext *)context;
+ (NSArray *)SK_allInContext:(NSManagedObjectContext *)context;
+ (NSArray *)SK_allWithPredicate:(NSPredicate *)pred inContext:(NSManagedObjectContext *)context;
+ (instancetype)SK_firstInContext:(NSManagedObjectContext *)context;
```

Mind the usage of `SK_inContext:` to retrieve an object in different read/write blocks (same read blocks are safe).


## Thread-safery notes

All the accesses to the persistence layer done via a `DALService` instance are guaranteed to be thread-safe.

It is highly suggested to enable the flag `-com.apple.CoreData.ConcurrencyDebug 1` in your project to make sure that the you don't misuse Core Data in terms of threading and concurrency (by accessing managed objects from different threads and similar errors).

This component doesn't aim to introduce interfaces with the goal of hiding the concept of `ManagedObjectContext`: it would open up the doors to threading issues in clients' code as developers should be responsible to check for the type of the calling thread at some level (that would be ignoring the benefits that Core Data gives to us).
Therefore, our design forces to make all the readings and writings via the `DALService` and the `ManagedObject` category methods are intended to always be explicit on the context (e.g. `SK_createInContext:`).
