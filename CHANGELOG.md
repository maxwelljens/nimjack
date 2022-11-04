# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [TODO] UNRELEASED

### Fixed:

- Don't shuffle the deck after every match. (This was discovered after releasing 1.0.0. Real blackjack is played without the deck being shuffled after every match.)

### Added:

- Tokens
- Doubling down
- Splitting
- Surrender

## [1.0.0] 2020-08-12

### Added

- Ability to specify amount of players between 2 and 4.
- One deck to play with
- Dealer hitting until 17 pips
- Ability to hit or stand
- Dealer matching the players when every player performed their turn
- Session tally of wins, draws, and losses until the player quits the match
