# Why?

Really, why? Expecially when there's so feature rich & mature solutions like MongoMapper and Mongoid? 
Actually, I know pretty well both of them, used in some projects and wrote extensions for both ([mongo_mapper_ext][mongo_mapper_ext], [mongoid_misc][mongoid_misc]).

The biggest problem with both of them - they introduce too much levels of abstraction, compexity and try to mimic ActiveRecord. 
Extra stuff is ok when it pays for itself, but in case of MongoDB it becames a butden with no value.

Let's see this in more detail:

1. Associations, the cornerstone of famous ActiveRecord. But in MongDB You can query only one collection per db-request (it doesn't support AR-style :include option). It means that if You consider the response time of Your application You cant use more than 2-4 associations (read - db-requests) per request. 
So, there will be little associations in Your (schema-less) database scheme. And, any of this association can be trivially done in 1-3 lines of raw code. So does it worth to add stuff like lazy-proxies, association-metadata, lots of options to remember, only to save couple lines of code? 
And even worse, sometimes You need something non-standard, and You has to dig-in and deal with all this complex association-implementing stuff to do it.

2. Query sugar - the same situations, query shugar in AR justified because SQL is complex and bloated - so there's a big payoff of using it. But the MongoDB query language is very simple and compact (and because there's no joins it's even more simple), so why should You bother to learn another one? Especially that in real situations You anyway frequently has to go down and do some data update, migration and other stuff using native MongoDB queries.
And^ the biggest disadvantage - sometimes You need it implement some custom query logic, and to do so You has to understand how this magic query sugar and abstraction stuff works inside.

3. Embedded documents, as I said before - there's no joins in MongoDB, but it has another strong side - embedded documents. So, let's see how well existing libraries support it? It's ok with simple cases, but when You need something more complicated - it's not an easy thing to do. Because of lot's of complexity and abstraction it's hard to do complex things with embedded documents. I.e. - it's hard to use one of the most stronges feature of MongoDB with these libraries. 
I implemented attachments stored as embedded documents (not files itself, metadata only) and it was very complicated to do because MongoMapper magically cleared some fields and Mongoid has really strange API design to work with embedded documents. 

Note: Association DSL & query sugar are great technics, but every technic has it's application scope. It works great with relational databases, in the ActiveRecord for example all this stuff & abstractions are useful, completely worth it's price, and gives lots of dividends. But MongoDB is different, and all those famous technics here are just a burden with no value.

It's hard to map objects to relational database, so it's ok that ORM are complicated, but mapping object to documents is trivial and there's no excuse for extra complexity of ODM.