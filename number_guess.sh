#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

echo "Enter your username:"
read USERNAME

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME';")

if [[ -z $PLAYER_ID ]]
then
  INSERT_PLAYER=$($PSQL "INSERT INTO players (username) VALUES ('$USERNAME');")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  PLAYER_INFO=$($PSQL "SELECT games_played, best_game FROM players WHERE username='$USERNAME';")
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$PLAYER_INFO"

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


SECRET=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

GET_GUESS() {
  (( NUMBER_OF_GUESSES++ ))
  read GUESS
}

echo "Guess the secret number between 1 and 1000:"
GET_GUESS

until [[ $GUESS -eq $SECRET ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again: "
  else
    if [[ $SECRET -lt $GUESS ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi

  GET_GUESS
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"
PLAYER_INFO=$($PSQL "SELECT games_played, best_game FROM players WHERE username='$USERNAME';")
IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$PLAYER_INFO"

(( GAMES_PLAYED++ ))
if [[ $BEST_GAME -gt $NUMBER_OF_GUESS || $BEST_GAME -eq 0 ]]
then
  SAVE_RESULT=$($PSQL "UPDATE players SET best_game=$NUMBER_OF_GUESSES, games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
else
  SAVE_RESULT=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
fi

