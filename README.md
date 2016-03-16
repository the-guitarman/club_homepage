[![Build Status](https://travis-ci.org/the-guitarman/club_homepage.svg?branch=master)](https://travis-ci.org/the-guitarman/club_homepage)
[![Code Climate](https://codeclimate.com/github/the-guitarman/club_homepage/badges/gpa.svg)](https://codeclimate.com/github/the-guitarman/club_homepage)
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://github.com/syl20bnr/spacemacs)

*Attention:* This is an after work project and neither it's finished nor it's ready for production usage.

# Club Homepage

This is a website skeleton for your soccer or handball club. It's a phoenixframework projekt written in elixir. The intension is not only the inform about the club. There is a back office to register and edit club members, create and edit teams, match lists, team selections and club news and there will be live events from running matches via channels (socket connections) so that other club members are informed about a running match asap.



## Installation

This is a phoenixframework app. So you need to install some requirements like Erlang, Elixir, Hex package manager, phoenix and node.js. See http://www.phoenixframework.org/docs/installation for more information.

Current Project Versions: 

- Elixir: v1.2.1
- Phoenix: v1.1.4

Now clone the project and install the project dependencies. Run these commands:

````
git clone git@github.com:the-guitarman/club_homepage.git
cd club_homepage
npm install
mix deps.get
````

### Database Setup

The project comes with sqlite support. You are free to use another database linke postgres or mysql. Don't forget to *change the username and password* to a role that has the correct database creation permissions. Therefore please see: 

- lib/club_homepage/repo.ex
- config/(dev|test|prod).ex

Now create and migrate the database:

````
mix ecto.create
mix ecto.migrate
````

## Configuration

### Translations

At the moment there are two languages which you can choose to run your side: english (en) and german (de, default). To change the default to en please edit the locale option within config/config.exs. 

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

### Logo & Background-Image



### Run

Run the app in production mode:

````
MIX_ENV=prod mix phoenix.server 
````

## License

Everything may break everytime. Therefore this package is licensed under
the **LGPL 3.0**. Do whatever you want with it, but please give improvements and bugfixes back so everyone can benefit.

## ToDos

- [ ] README.md
- [ ] Design
  - [ ] apple-touch-icon-precomposed.png
  - [ ] apple-touch-icon.png
- [ ] Plug
  - [ ] Permalink detection
- [ ] Models
  - [x] Address, with lat/lng
  - [ ] League
  - [x] Match
  - [ ] MatchEvent, e.g.: foul, red/yellow card
  - [ ] MatchHistory
  - [x] MeetingPoint
  - [x] OpponentTeam
  - [x] Permalink
  - [x] Season
  - [x] Secret
  - [x] Team
  - [x] User
- [ ] Controller
  - [x] create permalink redirection after slug change
- [ ] Tests
  - [ ] Models
    - [x] Address
    - [x] Match
    - [ ] MatchEvent
    - [ ] MatchHistory
    - [x] MeetingPoint
    - [x] OpponentTeam
    - [x] Permalink
    - [x] Season
    - [x] Secret
    - [x] Team
    - [x] User
  - [ ] Plugs
    - [ ] Auth
  - [ ] Commands
    - [ ] ModelValidator
    - [x] SlugGenerator
    - [ ] SecretCheck
    - [ ] UserRole
  - [ ] Controller
    - [x] AddressController
    - [x] MatchController
    - [ ] MatchEventController
    - [ ] MatchHistoryController
    - [x] MeetingPointController
    - [x] OpponentTeamController
    - [x] PermalinkController
    - [x] SeasonController
    - [x] SecretController
    - [x] TeamController
    - [x] UserController
- [ ] Sites
  - [ ] Homepage
    - [ ] no user is logged in, so show public news only
    - [ ] a user is logged in, show all news
    - [ ] show a list of active teams from current season
    - [ ] show a list of last matches, one for each active team
    - [ ] show a list of next matches, one for each active team
  - [ ] Back Office
    - [x] Redirect after login

# Help & Donation

Better ideas and solutions are gladly accepted. If you want to donate this project please use this link: https://paypal.me/guitarman/5
