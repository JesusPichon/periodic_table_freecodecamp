#!/bin/bash

# 1. Configure the variable to connect to PostgreSQL
# (Use -t and --no-align flags to get clean data separated by '|')
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# 2. Requirement: If no argument is provided, exit immediately
if [[ $# -eq 0 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# Save the user argument
INPUT=$1

# 3. Determine if the argument is a number (atomic_number) or text (symbol/name)
if [[ $INPUT =~ ^[0-9]+$ ]]
then
  QUERY_CONDITION="e.atomic_number = $INPUT"
else
  QUERY_CONDITION="e.symbol = '$INPUT' OR e.name = '$INPUT'"
fi

# 4. Get the data by performing JOINs between elements, properties, and types
ELEMENT_DATA=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number JOIN types t ON p.type_id = t.type_id WHERE $QUERY_CONDITION;")

# 5. Requirement: If the element does not exist in the database
if [[ -z $ELEMENT_DATA ]]
then
  echo "I could not find that element in the database."
else
  # 6. Read and format the row returned by PostgreSQL
  echo "$ELEMENT_DATA" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
  do
    # Requirement: Print the exact message requested by freeCodeCamp
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
