"""
    This script is a simple Tic Tac Toe game.
"""
import os
import sys
from random import randint
from copy import copy


def select_character():
    """
    Allows the player to choose his mark
    :return: player character
    """
    player = input("Pick your character: 'X' or 'O'. Q to exit")
    while True:
        if player.upper() == 'X':
            characters = player.upper(), 'O'
            break
        if player.upper() == 'O':
            characters = player.upper(), 'X'
            break
        if player.upper() == 'Q':
            sys.exit(0)
        else:
            player = input("Please pick character 'X' or 'O'. Q to exit ")

    return characters


def cls():
    """
    Clear system console
    :return:
    """
    os.system('cls' if os.name == 'nt' else 'clear')


def display_board(board):
    """
    Updates game board
    :param board: list with game state
    :return: string with updated game board
    """
    empty_board = """
___________________
|     |     |     |
|  7  |  8  |  9  |
|     |     |     |
|-----------------|
|     |     |     |
|  4  |  5  |  6  |
|     |     |     |
|-----------------|
|     |     |     |
|  1  |  2  |  3  |
|     |     |     |
|-----------------|
"""

    for i in range(1, 10):
        if board[i] == 'O' or board[i] == 'X':
            empty_board = empty_board.replace(str(i), board[i])
        else:
            empty_board = empty_board.replace(str(i), ' ')
    print(empty_board)


def place_marker(board, marker, selected_position):
    """
    places player marker on the selected position on board
    :param board: list with game state
    :param marker: player character
    :param selected_position: new player position
    :return:
    """
    board[selected_position] = marker
    return board


def space_check(board, selected_position):
    """
    checks if selected position is empty (equal to '#')
    :param board: list with game state
    :param selected_position: new player position
    :return: boolean
    """
    return board[selected_position] == '#'


def is_full(board):
    """
    checks if all positions on the board are filled
    :param board: list with game state
    :return: boolean
    """
    return len([x for x in board if x == '#']) == 1


def check_win(board, mark):
    """
    checks if current player wins
    :param board: list with game state
    :param mark: players character
    :return: boolean
    """
    result = False
    if board[1] == board[2] == board[3] == mark:
        result = True
    elif board[4] == board[5] == board[6] == mark:
        result = True
    elif board[7] == board[8] == board[9] == mark:
        result = True
    elif board[1] == board[4] == board[7] == mark:
        result = True
    elif board[2] == board[5] == board[8] == mark:
        result = True
    elif board[3] == board[6] == board[9] == mark:
        result = True
    elif board[1] == board[5] == board[9] == mark:
        result = True
    elif board[3] == board[5] == board[7] == mark:
        result = True
    return result


def player_choice(board):
    """
    asks player for his new position
    :param board: list with game state
    :return: players new position
    """
    choice = input("Please select an empty space between 1 and 9 : ")
    while not choice.isnumeric():
        choice = input("Selected field is not correct. Please choose between 1 and 9:")
    while not space_check(board, int(choice)):
        choice = input("This space isn't free. Please choose between 1 and 9 : ")
    return choice


def computer_choice(board, players):
    """
    Simple algorithm which ch
    :param players: players with characters
    :param board: list with game state
    :return: computers new position
    """

    # get available moves with scores
    moves = score_moves(board, players[1], players)

    # get the best move
    _, choice = max(moves, key=lambda m: m[0])

    return choice


def score_moves(board, current_marker, players):
    """
    Evaluates recursive possible moves
    If the move is a win it gets +1, if the move is a lose it gets -1,
    if there are no winners it gets 0.

    For movements without a winner, successive moves are recursively analyzed
    and the sum of their points is the result of the current move.

    :param players:
    :param board: list with game state
    :param current_marker: computers character
    """

    available_moves = (i for i, m in enumerate(board) if m == '#')

    for move in available_moves:
        proposal = copy(board)
        proposal[move] = current_marker

        # check if the current proposal wins
        if check_win(proposal, current_marker):
            # check if current_marker belongs to computer
            if current_marker == players[1]:
                score = 1
            else:
                score = -1
            yield score, move
            continue

        next_moves = list(score_moves(proposal, 'O' if current_marker == 'X' else 'X', players))
        if not next_moves:
            yield 0, move
            continue

        scores, _ = zip(*next_moves)

        yield sum(scores), move


def replay():
    """
    Asks the player to play again
    :return: boolean, players decision
    """
    play_again = input("Do you want to play again (y/n) ? Choose another key to exit")
    if play_again.lower() == 'y':
        result = True
    elif play_again.lower() == 'n':
        result = False
    else:
        sys.exit(0)
    return result


def main_loop():
    """
    Game main loop
    :return:
    """
    while True:
        round_number = randint(0, 1)  # randomly choose who is to start the game
        game_on = False
        main_board = ['#'] * 10

        players = select_character()  # Choose your character

        while not game_on:
            # Who's playin ?
            if round_number % 2 == 0:
                current_marker = players[1]
                if round_number == 0:
                    selected_position = 1
                else:
                    selected_position = computer_choice(main_board, players)
                    if selected_position == 0:
                        print("The game ended in a draw!")
                        break
                place_marker(main_board, current_marker, int(selected_position))
            else:
                current_marker = players[0]
                selected_position = player_choice(main_board)
                place_marker(main_board, current_marker, int(selected_position))

            # cls()
            display_board(main_board)

            # increment moves counter
            round_number += 1

            if check_win(main_board, current_marker):
                print("Player with character " + current_marker + " wins!")
                break

            game_on = is_full(main_board)
        if not replay():
            break


if __name__ == "__main__":
    main_loop()
    sys.exit(0)
