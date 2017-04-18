defmodule ClubHomepage.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: ClubHomepage.Repo

  # without Ecto
  #use ExMachina

  def address_factory do
    %ClubHomepage.Address{
      district: sequence(:district, &"District #{&1}"),
      street: sequence(:street, &"Street #{&1}"),
      zip_code: sequence(:zip_code, &"#{&1}#{&1}#{&1}#{&1}#{&1}"),
      city: "City"
    }
  end

  def beer_list_factory do
    user = insert(:user)
    deputy = insert(:user)
    %ClubHomepage.BeerList{
      user_id: user.id,
      deputy_id: user.id,
      title: sequence(:title, &"Team #{&1}"),
      price_per_beer: 1.0
    }
  end

  def beer_list_drinker_factopry do
    beer_list = insert(:beer_list)
    user = insert(:user)
    %ClubHomepage.BeerListDrinker{
      beer_list_id: beer_list.id,
      user_id: user.id,
      beers: sequence(:beers, &(&1))
    }
  end

  def competition_factory do
    %ClubHomepage.Competition{
      name: sequence(:name, &"League #{&1}"),
      matches_need_decition: false
    }
  end

  def match_factory do
    competition   = insert(:competition)
    season        = insert(:season)
    team          = insert(:team)
    opponent_team = insert(:opponent_team)
    %ClubHomepage.Match{
      competition_id: competition.id,
      season_id: season.id,
      team_id: team.id,
      opponent_team_id: opponent_team.id,
      #meeting_point_id: 1,
      start_at: Timex.local,
      home_match: false,
      description: nil,
      match_events: nil
    }
  end

  def news_factory do
    %ClubHomepage.News{
      subject: sequence(:subject, &"News Subject #{&1}"),
      body: sequence(:body, &"This is the news message #{&1}."),
      public: true
    }
  end

  def meeting_point_factory do
    address = insert(:address)
    %ClubHomepage.MeetingPoint{
      address_id: address.id,
      name: sequence(:name, &"Meeting Point #{&1}")
    }
  end

  def opponent_team_factory do
    %ClubHomepage.OpponentTeam{
      name: sequence(:name, &"Opponent Team #{&1}")
    }
  end

  def permalink_factory do
    team = insert(:team)
    %ClubHomepage.Permalink{
      source_path: sequence(:source_path, &"/teams/old-#{&1}"),
      destination_path: "/teams/#{team.slug}"
    }
  end

  def season_factory do
    %{year: year} = Timex.local
    %ClubHomepage.Season{
      name: sequence(:name, &"#{year}-#{year + &1}")
    }
  end

  def secret_factory do
    %ClubHomepage.Secret{
      key: SecureRandom.urlsafe_base64,
      expires_at: Timex.local |> Timex.add(Timex.Duration.from_days(7))
    }
  end

  def sponsor_image_factory do
    %ClubHomepage.SponsorImage{
      attachment: %{
        file_name: "test/support/images/test_image.jpg",
        updated_at: Ecto.DateTime.utc
      },
      name: sequence(:name, &"test image #{&1}")
    }
  end

  def team_factory do
    competition = insert(:competition)
    %ClubHomepage.Team{
      competition_id: competition.id, 
      name: sequence(:name, &"This is my    team #{&1} without ß in the name."),
      slug: sequence(:slug, &"this-is-my-team-#{&1}-without-ss-in-the-name")
    }
  end

  def team_chat_message_factory do
    team = insert(:team)
    user = insert(:user)
    %ClubHomepage.TeamChatMessage{
      team_id: team.id,
      user_id: user.id,
      message: sequence(:name, &"Hi there (#{&1})!")
    }
  end

  def team_image_factory do
    team = insert(:team)
    %ClubHomepage.TeamImage{
      team_id: team.id,
      year: 2016,
      attachment: %{
        file_name: "test/support/images/test_image.jpg",
        updated_at: Ecto.DateTime.utc
      },
      description: sequence(:description, &"team image description #{&1}")
    }
  end

  def text_page_factory do
    %ClubHomepage.TextPage{
      key: sequence(:key, &"contact #{&1}"),
      text: "How you can contact me: sajdlkasdiwdi"
    }
  end

  def unregistered_user_factory do
    %ClubHomepage.User{
      email: sequence(:email, &"mail-#{&1}@example.de"),
      name: sequence(:login, &"my name #{&1}"),
    }
  end

  def user_factory do
    %ClubHomepage.User{
      birthday: Timex.to_datetime({1988, 4, 17}, "UTC"), 
      email: sequence(:email, &"mail-#{&1}@example.de"),
      login: sequence(:login, &"my_login-#{&1}"), 
      name: sequence(:login, &"my name #{&1}"), 
      password_hash: Comeonin.Bcrypt.hashpwsalt("my password"),
      active: true,
      roles: "member administrator"
    }
  end
end
