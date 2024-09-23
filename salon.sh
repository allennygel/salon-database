#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"



SALON_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Hello welcome to our salon" 

  # get available services
  GET_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # if no services available
  if [[ -z $GET_SERVICES ]]
  then
    # send to main menu
    SALON_MENU "Sorry, we are having a problem with our system please try again later."
  else
    # display available services
    echo -e "\nand here are the services we have available:"
    echo "$GET_SERVICES" | while read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME" | sed 's/ |//'
    done

    # ask for service to avail
    echo -e "\nWhich one would you like to do today?"
    read SERVICE_ID_SELECTED

    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # if input is not a number or does not
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_NAME ]]
    then
      # send to main menu
      SALON_MENU "That is not a valid service number or it does not exist."
    else
      # get customer info
      echo -e "\nAlright before we start may I ask what's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nI couldn't find a match to your phone number.\nWhat's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      # get time
        echo -e "\nWhat time is it going to be?"
        read SERVICE_TIME

      # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")


      
        
      # send to main menu
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

      EXIT
    fi
  fi
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

SALON_MENU
