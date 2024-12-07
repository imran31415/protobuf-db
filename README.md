## protobuf-db
This package provides protobuf extension annotations.  These annotations allow user's who are defining protobufs to specify their SQL definitions in the same file as the protobuf. 

### Disclaimer: This project is in prototype/conceptual phase. not meant to be used in production. 

## Build:

```bash
./generate.sh  # builds protos 
```

## Quick start:

1. Import these annotations into your protobuf.  Here is an example "User" protobuf message definition augmented with the DB annotations defined in this package:


```protobuf
syntax = "proto3";
option go_package = "user/proto;proto";
package user;
import "google/protobuf/timestamp.proto";
import "github.com/imran31415/proto-db/database_operations.proto"; // Import the database options

// Message for the User entity
message User {
  int32 id = 1 [
    (db_annotations.db_column) = "id",
    (db_annotations.db_primary_key) = true,
    (db_annotations.db_column_type) = DB_TYPE_INT,
    (db_annotations.db_constraints) = DB_CONSTRAINT_NOT_NULL
  ];

  string username = 2 [
    (db_annotations.db_column) = "username",
    (db_annotations.db_column_type) = DB_TYPE_VARCHAR,
    (db_annotations.db_index) = true,
    (db_annotations.db_constraints) = DB_CONSTRAINT_NOT_NULL,
    (db_annotations.db_constraints) = DB_CONSTRAINT_UNIQUE
  ];

  string email = 3 [
    (db_annotations.db_column) = "email",
    (db_annotations.db_column_type) = DB_TYPE_VARCHAR,
    (db_annotations.db_index) = true,
    (db_annotations.db_constraints) = DB_CONSTRAINT_NOT_NULL,
    (db_annotations.db_constraints) = DB_CONSTRAINT_UNIQUE
  ];

  string hashed_password = 4 [
    (db_annotations.db_column) = "hashed_password",
    (db_annotations.db_column_type) = DB_TYPE_TEXT,
    (db_annotations.db_constraints) = DB_CONSTRAINT_NOT_NULL
  ];

  bool is_2fa_enabled = 5 [
    (db_annotations.db_column) = "is_2fa_enabled",
    (db_annotations.db_column_type) = DB_TYPE_BOOLEAN,
    (db_annotations.db_constraints) = DB_CONSTRAINT_NOT_NULL,
    (db_annotations.db_default) = DB_DEFAULT_FALSE
  ];

  string two_factor_secret = 6 [
    (db_annotations.db_column) = "two_factor_secret",
    (db_annotations.db_column_type) = DB_TYPE_VARCHAR
  ];

  google.protobuf.Timestamp created_at = 7 [
    (db_annotations.db_column) = "created_at",
    (db_annotations.db_column_type) = DB_TYPE_DATETIME,
    (db_annotations.db_constraints) = DB_CONSTRAINT_NOT_NULL,
    (db_annotations.db_default) = DB_DEFAULT_CURRENT_TIMESTAMP
  ];

  google.protobuf.Timestamp updated_at = 8 [
    (db_annotations.db_column) = "updated_at",
    (db_annotations.db_column_type) = DB_TYPE_DATETIME,
    (db_annotations.db_constraints) = DB_CONSTRAINT_NOT_NULL,
    (db_annotations.db_default) = DB_DEFAULT_CURRENT_TIMESTAMP,
    (db_annotations.db_update_action) = DB_UPDATE_ACTION_CURRENT_TIMESTAMP
  ];
}

```

## Using the annotations:

With these annotations you can use the `proto-db-translator` (https://github.com/imran31415/proto-db-translator)  go package, to automatically apply the SQL create table statements, generate the basic CRUD operations, and even auto generate more advanced queries, all though automatic code generation.  


### Example usage of annotations:

1. Create a 'protobuf-db' Translator type

```go
translator, err := NewTranslator(DefaultMysqlConnection())  // current supported options: [mysql, sqlite]
```

2. Validate the annotations in the protobuf:

```go
import "google.golang.org/protobuf/proto"
dsn := "username:password!@tcp(localhost)/testDb" // database connection string
translator.ValidateSchema(
    []proto.Message{&userauth.User{}, &userauth.Role{}, &userauth.UserRole{}}, // ordering matters, i.e UserRole has a fk relationship to Role.  So Role must be first in the list so the schema is aware of it.   
    dsn,

// you can also call translator.GenerateCreateTableStatement() to get the sql the annotations serialize to directly.   
// You can also pass 2 different proto types and get the migration with GenerateMigration()
```

ValidateSchema will:
   1. Attempt to generate a CREATE Table statement based on the message annotations defined.   
   2. Create a test database in the specified sql flavor and attempt to create the tables.   
   3. Delete the test database.    


3. Generate database CRUD in Golang based on the annotations defined:

```go
    // Protobuf messages to process
	protoMessages := []proto.Message{
		&userauth.User{}, // Replace with your actual proto message types
		&userauth.Role{},
		&userauth.RoleHierarchy{},
	}

	// Directory for generated models
	outputDir := "../models"

	// Call the refactored method
	err := translator.ProcessProtoMessages(outputDir, protoMessages)
```

The above will automatically generate the Go database code leveraging the XO library.   

```bash

<!-- All are autogenerated! -->
.models
├── db.xo.go    
├── role.xo.go  
├── rolehierarchy.xo.go
└── user.xo.go

```

The files listed above are generated by https://github.com/xo/xo and enable basic crud operations with the possibility of templating more complicated queries like MostRecent or Pagination.   


## Conclusion:

The above document outlines how to:

1. Add db annotations to your protobuf defintiion
2. Validate the annotations are appropriately applied
3. Create tables/migrations in SQL directly based on these annotations
4. Automatically Generate Go code to handle CRUD operations on the tables represented in annotations

Thanks for reading!

