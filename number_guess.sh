#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

# Check if user exists in the database
USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER_DATA ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
    IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while true; do
    read GUESS
    ((GUESSES++))

    # Check if input is an integer
    if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi

    if [[ $GUESS -eq $SECRET_NUMBER ]]; then
        echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
    elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
        echo "It's higher than that, guess again:"
    else
        echo "It's lower than that, guess again:"
    fi
done
# Update user's game record
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")

# Update best game if this game had fewer guesses
if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
    UPDATE_BEST_RESULT=$($PSQL "UPDATE users SET best_game = $GUESSES WHERE user_id = $USER_ID")
fi
# Added comment for random number generation
# Add check to prevent empty usernames# Added comment for random number generation
# Add check to prevent empty usernames
