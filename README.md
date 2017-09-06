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
