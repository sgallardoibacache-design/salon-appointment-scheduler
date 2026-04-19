#!/bin/bash

export PGPASSWORD=freecodecamp
PSQL="psql -h localhost --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo "Welcome to My Salon, how can I help you?"

  SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")"

  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")"

    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")"

      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" > /dev/null
      fi

      CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")"

      echo -e "\nWhat time would you like your $(echo "$SERVICE_NAME" | xargs), $(echo "$CUSTOMER_NAME" | xargs)?"
      read SERVICE_TIME

      $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" > /dev/null

      echo -e "\nI have put you down for a $(echo "$SERVICE_NAME" | xargs) at $SERVICE_TIME, $(echo "$CUSTOMER_NAME" | xargs)."
    fi
  fi
}

MAIN_MENU
