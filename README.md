# ADBCoreDataStack

A minimalistic design for a stack around Core Data

*Work in progress.*

In Core Data we usually call `performBlock:` on a context witha block that eventually will call `save:` on that context.
Magical Record provides API in the form of `saveWithBlock:`. Databases are all about reading and writings and for this reason our APIs in the CRUDService are in the form of `writeWithBlock:`.

The stack used is the one described [here](http://martiancraft.com/blog/2015/03/core-data-stack/) by Marcus Zarra.

Persistent Store Coordinator <- Private Context (NSPrivateQueueConcurrencyType) <- Main Context (NSMainQueueConcurrencyType) <- Slave Contexts (NSPrivateQueueConcurrencyType)

The basic design of ADBCoreDataStack involves a few main components:

- PersistenceController
- DALService (Data Access Layer)
- CoreDataStack
- Globals (singletons, yep... at some point to have something ready out-of-the-box you need singletons. Ease of use.)

An important difference from Magical Record is that saves always go in one direction, from slaves down (or up?) to the persistent store.
Magical Record allows you to create slaves that have the private context as parent and this causes the main context not to be updated or to be updated via notifications to merge the context.
The main context should be the source of truth and is tied to your UI, having a much simpler approach helps to create a system easier to reason about.
