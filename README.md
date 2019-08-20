[![Build Status](https://travis-ci.org/the-guitarman/club_homepage.svg?branch=master)](https://travis-ci.org/the-guitarman/club_homepage)
[![Code Climate](https://codeclimate.com/github/the-guitarman/club_homepage/badges/gpa.svg)](https://codeclimate.com/github/the-guitarman/club_homepage)
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://github.com/syl20bnr/spacemacs)

*Attention:* This is an after work project and neither it's finished nor it's ready for production usage.

# Club Homepage

This is a website system for your soccer club. It's a phoenixframework projekt written in elixir. The intension is not only the inform about the club. There is a back office to register and edit club members, create and edit teams, match lists, team selections and club news and there will be live events from running matches via channels (socket connections) so that other club members are informed about a running match asap.

## Features

- authentication and authorization system for club members
  - to register a user needs a secret key from the administrator
  - secrets have an expiry date, they are valid for one week
- editable standard pages (about us, registration information, history/chronicle, sponsors, contact)
- homepage with club logo, club news, team overview, latest matches and next matches
- news system with public and member news
- team pages with next matches, played matches and saison selection and team images
- next match page shows meeting point and match location at an open street map
- weather data for configurable coordinates (e.g.: match ground coordinates) 
- member birthdays of the next week
- payment lists (i.e.: beer list, penalty lists)
- team chats

## Installation

This is a phoenixframework app. So you need to install some requirements like Erlang, Elixir, Hex package manager, phoenix and node.js. See http://www.phoenixframework.org/docs/installation for more information.

Current Project Versions: 

- Elixir: v1.9
- Phoenix: v1.4.9

Now clone the project and install the project dependencies. Run these commands:

````
git clone git@github.com:the-guitarman/club_homepage.git
cd club_homepage
mix deps.get
cd assets && npm install
cd ..
````

Rename config files:
- config/club_homepage.exs.template -> config/club_homepage.exs
- config/prod.exs.template -> config/prod.exs
- config/dev.exs.template -> config/dev.exs
- config/test.exs.template -> config/test.exs

### Database Setup

The project uses a PostgreSQL database. You are free to use another database linke mysql. Don't forget to *change the username and password* to a role that has the correct database creation permissions. Therefore please see: 

- lib/club_homepage/repo.ex
- config/(dev|test|prod).exs

Now create and migrate the database:

````
mix ecto.create
mix ecto.migrate
````

### ImageMagick

- Ubuntu: `sudo apt-get update && sudo apt-get install imagemagick`
- Mac: `brew update && brew install imagemagick`

### Problems

If there are errors while uploading a sponsor or team image, then it could help to update imagemagick:

- Ubuntu: `sudo apt-get update && sudo apt-get upgrade imagemagick`
- Mac: `brew update && brew upgrade imagemagick`

## Configuration

### File Configurations

#### config/club_homepage.exs

At first copy `config/club_homepage.exs.template` to `config/club_homepage.exs`.

##### Settings

- :club_homepage, :common

Provide some information about your club.

- :elixir_weather_data, :api

If you want to show the current weather at your club match ground, please provide an api key, a language key (abbreviation) and the geo coordinates of the match ground for the openweathermap.org api. 

API Key: http://openweathermap.org/appid (You need to register a free account.)
Supported Languages: http://openweathermap.org/current#multi
Geo Coordinates: You may use one of the free map services like maps.bing.com or maps.google.com to find the coordinates of your match ground.

- :elixir_weather_data, :dev

There are two modes (development environment only).
`:sandbox` - shows preconfigured weather data
`:http_client` - downloads the weather data from the openweathermap.org api like in the production environment

- :club_homepage, :weather_data_units

Temperature: `:centigrade` or `:fahrenheit`
Wind Speed: `:kilometers_per_hour` or `:meters_per_second`

#### config/dev.exs

For development environment copy `config/dev.exs.template` to `config/dev.exs` and configure your database settings (database name/username/password).

#### config/prod.secret.exs

For production environment copy `prod.secret.exs.template` to `prod.secret.exs`, configure your database settings (database name/username/password) and don't forget to set your own secret. Therefore execute `mix phoenix.gen.secret` at the command line.

#### config/test.exs

Only needed, if you want to run the project tests.

For test environment copy `test.exs.template` to `test.exs` and configure your database settings (database name/username/password).

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

### Run

For development environment:

````
mix phx.server 
````

See `http://localhost:4000`


For production environment:

At first open config/prod.exs and set your host name or ip address.

````
MIX_ENV=prod PORT=80 mix phx.server 
````

At this point you should have a running app. Please log in with the administrator user, you seeded in before.

### Edit Text Pages

Please click to open "master data -> text pages" in the top navbar. Text pages are all static sites like "about us", "contact", "chronicle", "registration information" and "sponsors". These sites have no content right now. You may edit the pages now to fill them.

### Static Assets

#### Favicon and Apple-Touch-Icon

You may create the image files:

- `assets/static/favicon.ico`
- `assets/static/images/favicon_32x32.png`
- `assets/static/images/favicon_96x96.png`
- `assets/static/images/apple_touch_icon_180x180.png`

#### Logo

To show a small logo instead of the short club name in the top navbar you need to create the image `assets/static/images/logo\_navbar\_20x20.png`. This image will be used as homepage link. 

To show a logo in the middle of the homepage you need to create the image `assets/static/images/logo.png`. A good size may be 160x160 pixel.

#### Background

To change the background image you need to replace the image `assets/static/images/background_01.jpg` with another one.

To remove the background image open `lib/club_homepage/web/templates/web/layout/app.html.eex` and remove the css class `background-image-01` from the body element.

#### humans.txt

You may provide a `/humans.txt`. Therefore copy `assets/static/humans.template.txt` to `assets/static/humans.txt` and edit its content. Here are more information about [humans.txt](http://humanstxt.org/).

## Releases

To create a release you my use [Distillery](https://hexdocs.pm/distillery). Therefore copy `rel/config.exs.template` to `rel/config.exs` and edit it to your needs. Then run these commands in the project root: 

```
cd assets && ./node_modules/brunch/bin/brunch build --production && cd ..
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release --env=prod
```

## License

This project has a dual license.

This package is licensed under
the **LGPL 3.0**. Do whatever you want with it, but please give improvements and bugfixes back so everyone can benefit.

For commercial usage please contact me at first.

*Note:* Everything may break at every time.

# Help & Donation

Better ideas and solutions are gladly accepted. If you want to donate this project please use this link: [Donate](https://paypal.me/guitarman/5)

# Todos

- [ ] edit robots.txt and humans.txt in the back office from the administrator only
