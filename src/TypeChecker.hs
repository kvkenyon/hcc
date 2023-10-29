module TypeChecker where

{-- Symbol Table

First we construct a symbol table for:
a. Formal Parameters and Variable names
b. Method Name
c. Struct/Union/Enum (TODO: Need to add support for structs etc. later)

We will represent each symbol name as a String for now (TODO: Use Data.Text for strings)

A symbol will point to a binding which is the type.

-}