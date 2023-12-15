# Program written by Maxwell Jensen (c) 2022
# Licensed under European Union Public Licence 1.2.
# For more information, consult README.md or man page

import docopt, random, strutils, terminal


type
  Cards = seq[int]
  Result = enum
    Nothing,
    Win,
    Draw,
    Loss,
    Bust
  Player = object
    cards: Cards
    name: string
    wins: int
    draws: int
    losses: int
  StdDeck = array[0..51, tuple[name: string, pip: int]]


const
  Introduction =
    """ooooo      ooo  o8o                     o8o                     oooo        
`888b.     `8'  `"'                     `"'                     `888        
 8 `88b.    8  oooo  ooo. .oo.  .oo.   oooo  .oooo.    .ooooo.   888  oooo  
 8   `88b.  8  `888  `888P"Y88bP"Y88b  `888 `P  )88b  d88' `"Y8  888 .8P'   
 8     `88b.8   888   888   888   888   888  .oP"888  888        888888.    
 8       `888   888   888   888   888   888 d8(  888  888   .o8  888 `88b.  
o8o        `8  o888o o888o o888o o888o  888 `Y888""8o `Y8bod8P' o888o o888o 
Welcome to Nimjack, a CLI-based game of blackjack, written in Nim.
Type 'q' at any time to quit the game.  888                                 
                                    .o. 88P                                 
                                    `Y888P """

  UsageInstructions =
    """Nimjack - CLI game of blackjack written in Nim.
Specify no options to play the game with default settings.

Usage:
  nimjack -h | --help
  nimjack [options]

Options:
  -a --always       Play always first.
  -h --help         View this help and exit.
  -o --anglo        Play with Anglospheric player names and card suits.
  -v --version      Output version information and exit."""

  Version =
    """nimjack 1.0.0
Copyright (C) 2020 Maxwell Jensen
Licensed under European Union Public Licence 1.2.
For more information, consult README.md or man page
"""

  GermanDeck: StdDeck =
  # 0
    [("Ace of Clovers", 11), ("Two of Clovers", 2), ("Three of Clovers", 3), ("Four of Clovers", 4),
("Five of Clovers", 5), ("Six of Clovers", 6), ("Seven of Clovers", 7), ("Eight of Clovers", 8),
("Nine of Clovers", 9), ("Ten of Clovers", 10), ("Jack of Clovers", 10), ("Queen of Clovers", 10),
("King of Clovers", 10),
  # 13
("Ace of Tiles", 11), ("Two of Tiles", 2), ("Three of Tiles", 3), ("Four of Tiles", 4), ("Five of Tiles", 5),
("Six of Tiles", 6), ("Seven of Tiles", 7), ("Eight of Tiles", 8), ("Nine of Tiles", 9), ("Ten of Tiles", 10),
("Jack of Tiles", 10), ("Queen of Tiles", 10), ("King of Tiles", 10),
  # 26
("Ace of Hearts", 11), ("Two of Hearts", 2), ("Three of Hearts", 3), ("Four of Hearts", 4), ("Five of Hearts", 5),
("Six of Hearts", 6), ("Seven of Hearts", 7), ("Eight of Hearts", 8), ("Nine of Hearts", 9), ("Ten of Hearts", 10),
("Jack of Hearts", 10), ("Queen of Hearts", 10), ("King of Hearts", 10),
  # 39
("Ace of Acorns", 11), ("Two of Acorns", 2), ("Three of Acorns", 3), ("Four of Acorns", 4), ("Five of Acorns", 5),
("Six of Acorns", 6), ("Seven of Acorns", 7), ("Eight of Acorns", 8), ("Nine of Acorns", 9), ("Ten of Acorns", 10),
("Jack of Acorns", 10), ("Queen of Acorns", 10), ("King of Acorns", 10)]
  AngloDeck: StdDeck =
  # 0
    [("Ace of Clubs", 11), ("Two of Clubs", 2), ("Three of Clubs", 3), ("Four of Clubs", 4), ("Five of Clubs", 5),
("Six of Clubs", 6), ("Seven of Clubs", 7), ("Eight of Clubs", 8), ("Nine of Clubs", 9), ("Ten of Clubs", 10),
("Jack of Clubs", 10), ("Queen of Clubs", 10), ("King of Clubs", 10),
  # 13
("Ace of Diamonds", 11), ("Two of Diamonds", 2), ("Three of Diamonds", 3), ("Four of Diamonds", 4),
("Five of Diamonds", 5), ("Six of Diamonds", 6), ("Seven of Diamonds", 7), ("Eight of Diamonds", 8),
("Nine of Diamonds", 9), ("Ten of Diamonds", 10), ("Jack of Diamonds", 10), ("Queen of Diamonds", 10),
("King of Diamonds", 10),
  # 26
("Ace of Hearts", 11), ("Two of Hearts", 2), ("Three of Hearts", 3), ("Four of Hearts", 4), ("Five of Hearts", 5),
("Six of Hearts", 6), ("Seven of Hearts", 7), ("Eight of Hearts", 8), ("Nine of Hearts", 9), ("Ten of Hearts", 10),
("Jack of Hearts", 10), ("Queen of Hearts", 10), ("King of Hearts", 10),
  # 39
("Ace of Spades", 11), ("Two of Spades", 2), ("Three of Spades", 3), ("Four of Spades", 4), ("Five of Spades", 5),
("Six of Spades", 6), ("Seven of Spades", 7), ("Eight of Spades", 8), ("Nine of Spades", 9), ("Ten of Spades", 10),
("Jack of Spades", 10), ("Queen of Spades", 10), ("King of Spades", 10)]
  Aces: array[0..3, int] = [0, 13, 26, 39]

  AngloNames: array[0..9, string] =
    ["Adam", "Arthur", "Benjamin", "Bob", "James", "John", "Matthew", "Reginald", "Ronald", "Winston"]
  EuropeanNames: array[0..9, string] =
    ["Benito", "DeGaulle", "Grzegorz", "Hansen", "Johannes", "Kamil", "Santiago", "Simon", "Steinar", "Svensson"]

  BasicStrategy: array[0..12, tuple[card: array[0..3, int], action: array[0..5, bool]]] =
  # 0: 18-21 | 1: 17 | 2: 16 | 3: 15 | 4: 13-14 | 5: 5-12
    [([0, 13, 26, 39], [false, true, true, true, true, true]),
  ([1, 14, 27, 40], [false, false, false, false, false, true]),
  ([2, 15, 28, 41], [false, false, false, false, false, true]),
  ([3, 16, 29, 42], [false, false, false, false, false, false]),
  ([4, 17, 30, 43], [false, false, false, false, false, false]),
  ([5, 18, 31, 44], [false, false, false, false, false, false]),
  ([6, 19, 32, 45], [false, false, true, true, true, true]),
  ([7, 20, 33, 46], [false, false, true, true, true, true]),
  ([8, 21, 34, 47], [false, false, true, true, true, true]),
  ([9, 22, 35, 48], [false, false, true, true, true, true]),
  ([10, 23, 36, 49], [false, false, true, true, true, true]),
  ([11, 24, 37, 50], [false, false, true, true, true, true]),
  ([12, 25, 38, 51], [false, false, true, true, true, true])]


var
# Game options
  optTransparent: bool
  optAlwaysFirst: bool
  optAnglo: bool
  optPlayers: int
  #optDifficulty: int
# Game assets
  players: seq[Player]
  userPlayer: int
  theDeck: Cards
  dealerHand: Cards


# Randomize random number generator seed. Very important.
randomize()

proc checkExit(x: char, confirm: bool = true) =
  ## If any player input `x` is `char 'q'`, terminate the program. If `confirm` is `true`, which it should be during 
  ## games, prompt the user. `confirm` is `true` by default.
  if x == 'q':
    case confirm
    of false:
      echo "Terminating program."
      system.quit()
    of true:
      echo "DEALER: You are in a match. Are you sure you want to quit? ([y]es, [n]o)"
      let readInput = getch()
      if readInput in ['y', 'Y']:
        echo "DEALER: See you next time."
        system.quit()

proc getCardName(x: int): string =
  case optAnglo
  of false:
    GermanDeck[x][0]
  of true:
    AngloDeck[x][0]

proc getCardPip(x: int): int =
  case optAnglo
  of false:
    GermanDeck[x][1]
  of true:
    AngloDeck[x][1]

proc returnAces(): int =
  ## Returns the amount of aces in dealer's hand
  for x in 0..dealerHand.high:
    if x in Aces:
      result += 1

proc returnAces(player: int): int =
  ## Returns the amount of aces in `player`'s (player index) hand
  for x in players[player].cards:
    if x in Aces:
      result += 1

proc returnPip(): int =
  ## Return the total pip value of the dealer's hand.
  var totalPip: int
  for x in 0..dealerHand.high:
    totalPip += getCardPip(dealerHand[x])
  if totalPip > 21:
    totalPip -= returnAces() * 10
  return totalPip

proc returnPip(player: int): int =
  ## Return the total pip value of `player`'s (player index) hand.
  var totalPip: int
  for x in 0..players[player].cards.high:
    totalPip += getCardPip(players[player].cards[x])
  if totalPip > 21:
    totalPip -= returnAces(player) * 10
  return totalPip

proc echoHand() =
  ## Echo the hand of the dealer.
  var strToEcho: string
  for x in 0..dealerHand.high:
    add(strToEcho, " ")
    add(strToEcho, getCardName(dealerHand[x]))
    if x < dealerHand.high:
      add(strToEcho, ",")
  echo "DEALER'S hand is", strToEcho, ". (", returnPip(), ")"

proc echoHand(player: int) =
  ## Echo the hand of a `player` (player index).
  var strToEcho: string
  for x in 0..players[player].cards.high:
    add(strToEcho, " ")
    add(strToEcho, getCardName(players[player].cards[x]))
    if x < players[player].cards.high:
      add(strToEcho, ",")
  if player == userPlayer:
    echo "YOUR hand is", strToEcho, ". (", returnPip(player), ")"
  else:
    echo players[player].name, "'s hand is", strToEcho, ". (", returnPip(player), ")"

proc evaluateHands(player: int, adversarial: bool = true): Result =
  ## Evaluate hands by comparing `player`'s (player index) hand to the dealer's hand if `adversarial` is `true`.
  ## If `adversarial` is `false`, simply check the player's hand for a bust. `adversarial` is `true` by default.
  var playerPip = returnPip(player)
  let dealerPip = returnPip()
  case adversarial
  of true:
    # If `player` pip is over 21, modify pip by reducing it with aces, if there are any.
    # Test the modified value further. Otherwise, player busts.
    if playerPip > 21:
      return Bust
    if dealerPip > playerPip and dealerPip <= 21:
      return Loss
    elif dealerPip == playerPip and dealerPip <= 21:
      return Draw
    elif (dealerPip < playerPip) or (dealerPip > 21 and playerPip <= 21):
      return Win
  of false:
    if playerPip > 21:
      echo players[player].name, ": Bust."
      return Bust
    else:
      return Nothing

proc drawCard() =
  ## Make the dealer draw cards from the deck until he is above 17 pips. This changes the deck.
  dealerHand.insert(theDeck.pop())
  echo "DEALER'S exposed card is *[", getCardName(dealerHand[0]), "]*."
  dealerHand.insert(theDeck.pop())
  var cardsDrawn = 2
  while true:
    if returnPip() < 17:
      dealerHand.insert(theDeck.pop())
      cardsDrawn += 1
    else:
      break
  echo "DEALER has a total of ", cardsDrawn, " cards."

proc drawCard(player: int, dealt: bool = false) =
  ## Make `player` (player index) draw a card from the deck. This changes the deck. The move is echoed if the drawing
  ## player is the user or `optTransparent` is `true`. If `dealt` is `true`, this information is conveyed as the
  ## dealer dealing the cards to the player. `dealt` is `false` by default.
  players[player].cards.insert(theDeck.pop())
  case dealt
  of false:
    if player == userPlayer:
      echo "YOU drew ", getCardName(players[player].cards[0]), "."
    elif optTransparent == true:
      echo players[player].name, " drew ", getCardName(players[player].cards[0]), "."
  of true:
    if player == userPlayer:
      echo "DEALER dealt YOU ", getCardName(players[player].cards[0]), "."
    elif optTransparent == true:
      echo "DEALER dealt ", players[player].name, " ", getCardName(players[player].cards[0]), "."
    else:
      echo "DEALER dealt ", players[player].name, " a card."

proc analysis(pip: int): bool =
  ## Analyse total pip of a hand and return `true` or `false` based on `BasicStrategy`
  for x in BasicStrategy:
    if dealerHand[dealerHand.high] in x[0]:
      case pip
      of int.low..12: return x[1][5]
      of 13, 14: return x[1][4]
      of 15: return x[1][3]
      of 16: return x[1][2]
      of 17: return x[1][1]
      of 18..int.high: return x[1][0]

proc promptAction() =
  ## Make the dealer do his thing.
  for x in 0..players.high:
    echoHand(x)
    case evaluateHands(x)
    of Bust:
      echo "DEALER to ", players[x].name,": That is a bust."
      players[x].losses += 1
    of Loss:
      echo "DEALER to ", players[x].name,": You lose."
      players[x].losses += 1
    of Draw:
      echo "DEALER to ", players[x].name,": A draw. Neither of us win."
      players[x].draws += 1
    of Win:
      echo "DEALER to ", players[x].name,": That's a win."
      players[x].wins += 1
    else: discard

proc promptAction(player: int) =
  ## Prompt action from user player or make AI player act.
  if player == userPlayer:
    echo "[h]it | [s]tand"
    while true:
      let readInput = getch()
      checkExit(readInput)
      case readInput
      of 'h', 'H':
        drawCard(player)
        echoHand(player)
        case evaluateHands(player, false)
        of Bust: break
        else: discard
      of 's', 'S':
        break
      else:
        discard
    echo "--- YOU END YOUR TURN ---"
  else:
    while true:
      case analysis(returnPip(player))
      of true:
        drawCard(player)
      of false: break
    echo players[player].name, " has a total of ", players[player].cards.len(), " cards."

proc echoMatchResults() =
  echo "---- SESSION RESULTS ----"
  for x in 0..players.high:
    echo players[x].name, ": ", players[x].wins, " wins, ", players[x].draws, " draws, ", players[x].losses, " losses."

proc initGame() =
  # Set up player count
  echo "Select your player count (2-4)"
  while true:
    let readInput = getch()
    if readInput in ['2', '3', '4']:
      optPlayers = parseInt($readInput)
      echo "The player count shall be ", readInput, "."
      break # Move on
    else:
      checkExit(readInput, false)
      echo "That was not a valid number. Try again."
 
  #[ Set up difficulty
  echo "Select your difficulty ([e]asy, [n]ormal, [h]ard)"
  while true:
    let readInput = getch()
    case readInput:
    of 'e', 'E':
      optDifficulty = 0
      echo "The difficulty shall be EASY."
      break # Move on
    of 'n', 'N':
      optDifficulty = 1
      echo "The difficulty shall be NORMAL."
      break # Move on
    of 'h', 'H':
      optDifficulty = 2
      echo "The difficulty shall be HARD."
      break # Move on
    else:
      checkExit(readInput, false)
      echo "Did not get that. Try again."
  ]#

proc initPlayers() =
    # Initialize players
  var pickedNames: seq[string]
  let names = case optAnglo
    of false: EuropeanNames
    of true: AngloNames
  while true:
    var pick = sample(names)
    if pick in pickedNames:
      continue
    else:
      players.insert(Player(name: pick))
      if players.len == optPlayers:
        break
      pickedNames.insert(pick)
 
  # Select a random player to be the user
  case optAlwaysFirst
  of false: userPlayer = rand(players.high)
  of true: userPlayer = 0
  players[userPlayer].name = "YOU"

proc initDeck() =
  # Flush all cards of all players, the dealer, and in the deck
  for x in 0..players.high:
    players[x].cards = @[]
  dealerHand = @[]
  theDeck = @[]
 
  # Initialize house deck
  for x in 0..StdDeck.high:
    theDeck.insert(x)
  shuffle(theDeck)
  echo "The house deck has been stacked and shuffled. Dealing cards now."
 
  # Deal the cards
  var dealingCards = true
  while dealingCards:
    for x in 0..players.high:
      if players[x].cards.high < 1:
        drawCard(x, true)
      else:
        dealingCards = false
        drawCard()
        break
  echoHand(userPlayer)

proc gameLoop() =
  while true:
    initDeck()
    for x in 0..players.high:
      promptAction(x)
    echoHand()
    echo "----- DEALER'S TURN -----"
    promptAction()
    echoMatchResults()
    echo "Continue the game? ([y]es, [n]o)"
    let readInput = getch()
    case readInput
    of 'n', 'N':
      echo "DEALER: It was a good match. See you later."
      system.quit()
    else: discard

# Read passed CLI options
proc readOpts =
  let opts = docopt(doc = UsageInstructions, version = Version)
  if opts["--always"]: optAlwaysFirst = true
  if opts["--anglo"]: optAnglo = true

proc main =
  readOpts()
  echo Introduction
  initGame()
  initPlayers()
  gameLoop()

main()
