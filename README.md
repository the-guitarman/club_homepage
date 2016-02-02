[![Build Status](https://travis-ci.org/the-guitarman/club_homepage.svg?branch=master)](https://travis-ci.org/the-guitarman/club_homepage)
[![Test Coverage](https://codeclimate.com/github/the-guitarman/club_homepage/badges/coverage.svg)](https://codeclimate.com/github/the-guitarman/club_homepage/coverage)
[![Issue Count](https://codeclimate.com/github/the-guitarman/club_homepage/badges/issue_count.svg)](https://codeclimate.com/github/the-guitarman/club_homepage)
[![Code Climate](https://codeclimate.com/github/the-guitarman/club_homepage/badges/gpa.svg)](https://codeclimate.com/github/the-guitarman/club_homepage)
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://github.com/syl20bnr/spacemacs)

*Attention:* This is an after work project and neither it's finished nor it's ready for production usage.

# Club Homepage

This is a website skeleton for your soccer or handball club. It's a phoenixframework projekt written in elixir. The intension is not only the inform about the club. There is a back office to register and edit club members, create and edit teams, match lists, teams selections and club news and there will be live events from running matches via channels (socket connections) so that other club members are informed about a running match asap.



## Installation

This is a phoenixframework app. So you need to install some requirements like Erlang, Elixir, Hex package manager, phoenix and node.js. See http://www.phoenixframework.org/docs/installation for more information.

After this install project dependencies Run this commands from the project root:

````
npm install
mix deps.get
````

### Seed Data

At first edit priv/repo/seeds.exs. You need to edit the administrator attributes. Don't forget to set a new password. Next you edit the data to fit your needs and provide first setup for your club data. Create the teams of your club, the season you need, the opponent teams of your league, addresses and meeting points. After that you seed your data into the database with one of the following commands: 

For development environment
````
MIX_ENV=dev mix run priv/repo/seeds.exs
````

For production environment:
````
MIX_ENV=prod mix run priv/repo/seeds.exs
````

## License

Everything may break everytime. Therefore this package is licensed under
the **LGPL 3.0**. Do whatever you want with it, but please give improvements and bugfixes back so everyone can benefit.

## ToDos

- [ ] write README.md
- [ ] Models
  - [x] Address, with lat/lng
  - [ ] League
  - [x] Match
  - [ ] MatchEvent, e.g.: foul, red/yellow card
  - [ ] MatchHistory
  - [x] MeetingPoint
  - [x] OpponentTeam
  - [x] Season
  - [x] Secret
  - [x] Team
  - [x] User
- [ ] Tests
  - [ ] Models
    - [ ] Address
    - [ ] Match
    - [ ] MatchEvent
    - [ ] MatchHistory
    - [ ] MeetingPoint
    - [ ] OpponentTeam
    - [ ] Season
    - [x] Secret
    - [ ] Team
    - [x] User
  - [ ] Plugs
    - [ ] Auth
  - [ ] Commands
    - [ ] ModelValidator
    - [ ] RewriteGenerator
    - [ ] SecretCheck
    - [ ] UserRole
  - [ ] Controller
    - [ ] AddressController
    - [ ] MatchController
    - [ ] MatchEventController
    - [ ] MatchHistoryController
    - [ ] MeetingPointController
    - [ ] OpponentTeamController
    - [ ] SeasonController
    - [x] SecretController
    - [ ] TeamController
    - [x] UserController
- [ ] Sites
  - [ ] Homepage
    - [ ] no user is logged in, so show public news only
    - [ ] a user is logged in, show all news
    - [ ] show a list of active teams from current season
    - [ ] show a list of last matches, one for each active team
    - [ ] show a list of next matches, one for each active team
  - [ ] Back Office

# Help & Donation

Better ideas and solutions are gladly accepted. If you want to donate this project please use this link: https://paypal.me/guitarman/5
