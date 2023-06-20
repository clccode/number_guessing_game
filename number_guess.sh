#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~ Number Guessing Game ~~\n"
echo "Enter your username: "
read USERNAME

# Look up user in database
USER_LOOKUP=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
# get user_id
USER_ID=$($PSQL "SElECT user_id FROM users WHERE username = '$USERNAME'")

# if user not in database
if [[ -z $USER_LOOKUP ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  # insert user into database
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
# else if the user is found
else
  # get number of games played
  GAMES_PLAYED=$($PSQL "SELECT count(guesses) FROM games WHERE user_id=$USER_ID")
  # get lowest score
  BEST_GAME=$($PSQL "SELECT min(guesses) FROM games WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# generate a random number between 1 and 1000
RANDOM_NUM=$(( ( RANDOM % 1000) + 1 ))

# set user tries to 0
TRIES=0

# get user's first guess
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

# unitl loop to prompt guess until the user gets it right
until [[ $GUESS == $RANDOM_NUM ]]
do
  # check if guess is a valid integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
    ((TRIES++))
  else # check if guess smaller or larger than the random number
    if [[ $GUESS < $RANDOM_NUM ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      read GUESS
      ((TRIES++))
    elif [[ $GUESS > $RANDOM_NUM ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      read GUESS
      ((TRIES++))
    fi
  fi
done

# if user guesses the number the loop ends
((TRIES++))

# Get user_id
USER_ID=$($PSQL "SElECT user_id FROM users WHERE username = '$USERNAME'")

# insert game into database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRIES)")

# print message
echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUM. Nice job!"
