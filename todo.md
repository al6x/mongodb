- add validates_uniquiness_of
- file_model

- identity map
- reload ?
- MongoMapper::Modifiers ?
- timestamps!
- MongoMapper::Validations ?
- replace initialize with set
- allow to specify type-conversion block in assignment

# Low

- destroy_all

# Readme

Existing ODM like MongoMapper and Mongoid are trying to hide
Other ODM usually try to cover simple but non-standard API of MongoDB with complex ORM-like abstractions. This tool exposes simplicity and power of MongoDB and leverages it's differences.

Model designed after the excellent "Domain-Driven Design" book by Eric Evans.

# Done


# Rejected

- :name.lt => 'value'
- use another defaults by default