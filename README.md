Trineo Todo API
===============

This is the Trineo Todo API.  This API is deployed for the fictional Death
Star Corp who use it to manage pending work.  The most prominent user is
the chief engineer in the exhaust ports department, who has 5000 todos and
25,000 items on his todo list.

Instructions
------------
- Spend 2 hours max on the feature request below.
- Work with a complete and 'production ready' mindset, including making
  commits as you would for a pull request that will be reviewed.
- Return a zip with your version controlled project via email.

Feature request
---------------

The following new feature has been requested for the API:

- **Add completed flag to Todos** - add a new `completed` boolean flag to the
  JSON representation of a `Todo`.  A `Todo` is considered to be completed when
  all of it's `Item`s are completed.  If a `Todo` has no `Item`s, it should
  be considered *not* completed.

Setup
-----
```
$ rake db:setup
$ rake spec
```

The API is quite simple, it represents Todos, and each Todo has many items

![Trineo Todo API ERD](doc/erd.png)

Usage
-----

```
# Create a Todo
$ curl -X POST -d 'title=New+TODO' http://localhost:3000/todos
{
  "id":1,
  "title":"New TODO",
  "created_at":"2017-07-06T22:05:04.065Z",
  "updated_at":"2017-07-06T22:05:04.065Z"
}

# Create an Item
$ curl -X POST -d 'title=First Item' http://localhost:3000/todos/1/items
{
  "id":1,
  "title":"First Item",
  "completed":false,
  "todo_id":1,
  "created_at":"2017-07-06T22:06:49.175Z",
  "updated_at":"2017-07-06T22:06:49.175Z"
}

# List Todos
$ curl http://localhost:3000/todos
[
   {
      "id" : 1,
      "updated_at" : "2017-07-06T22:05:04.065Z",
      "created_at" : "2017-07-06T22:05:04.065Z",
      "title" : "New TODO"
   }
]

# List items
curl http://localhost:3000/todos/1/items
[
   {
      "updated_at" : "2017-07-06T22:06:49.175Z",
      "created_at" : "2017-07-06T22:06:49.175Z",
      "completed" : false,
      "todo_id" : 1,
      "title" : "First Item",
      "id" : 1
   }
]

# Update an item
$ curl -X PATCH -d 'completed=true' http://localhost:3000/todos/1/items/1
{
   "title" : "First Item",
   "updated_at" : "2017-07-06T22:10:43.140Z",
   "created_at" : "2017-07-06T22:06:49.175Z",
   "todo_id" : 1,
   "id" : 1,
   "completed" : true
}
```

New Feature Notes
-----------------

My first observation is that the chief engineers large number of todos and items means we need to consider performance implications carefully. Specifically we need to avoid N+1s when listing todos and make sure todos and items tables are indexed properly. todos already does have an index on item_id so we do not have to be concerned about indexes at this stage.

There are a few ways to implement this new feature:

1 - As a derived boolean flag which is calculated every time it needs to be returned.

2 - By caching a completed boolean flag directly on the todos table. This means it may need to be updated any time an item is created, updated OR deleted.

3 - By caching counts of the total number of items AND the number of completed items on the todos table.

Option 1 would make it very difficult (although not impossible) to avoid an N+1 query when listing todos. Essentially it would require a significant modification of the resource collection scope using a group by and attr_accessors for count of completed items per todo and total items per todo. Such an approach complicates the query and potentially introduces some other difficulties with ActiveRecord down the track. A naive implementation of option 1 would calculate the counts by instantiating an AR instance for each record and then performing a count of total/complete items for each todo which is **really bad** for performance.

Option 2 is relatively simple to implement and should avoid performance issues without introducing too much complexity. We just need to be careful to properly set the flag and make sure we do so without introducing possible locking issues.

Option 3 can be dismissed as it likely adds complexity without any obvious benefits over option 2.

Having chosen option 2, after adding the flag to the table via a migration we should really write a data migration or rake task which will populate existing todos completed flag and set them correctly. It is then a matter of adding or modifying existing tests to properly capture the desired new functionality and then write the code needed to make these tests pass.

One other thing to note - by avoiding callback pain and placing the responsibility for keeping todos synchronised with items within the controller, we are assuming that **all** CRUD actions to the database are **always** carried out via the API. This might not be a realistic or completely safe assumption. It also means tests need to explicitly set the todo flag when setting up data since it will not be set by the model.

I have written a sample rake task in migration.rake which updates all todos. It may be argued this could be encapsulated in a class method for todos but this envisaged to be a once off so it might be better left where it is.