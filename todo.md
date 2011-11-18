- identity map ?

# Low

- destroy_all

# Readme

Existing ODM like MongoMapper and Mongoid are trying to hide
Other ODM usually try to cover simple but non-standard API of MongoDB with complex ORM-like abstractions. This tool exposes simplicity and power of MongoDB and leverages its differences.

Model designed after the excellent "Domain-Driven Design" book by Eric Evans.

# Done

- add validates_uniquiness_of
- file_model
- reload
- timestamps
- replace initialize with set
- allow to specify type-conversion block in assignment

# Rejected

- :name.lt => 'value'
- use another defaults by default