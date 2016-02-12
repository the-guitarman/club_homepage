defmodule ClubHomepage.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: ClubHomepage.Repo

  # without Ecto
  #use ExMachina

  def factory(:address) do
    %ClubHomepage.Address{
      district: sequence(:district, &"District #{&1}"),
      street: sequence(:street, &"Street #{&1}"),
      zip_code: sequence(:zip_code, &"#{&1}#{&1}#{&1}#{&1}#{&1}"),
      city: "City"
    }
  end

  def factory(:match) do
    season        = create(:season)
    team          = create(:team)
    opponent_team = create(:opponent_team)
    %ClubHomepage.Match{
      season_id: season.id,
      team_id: team.id,
      opponent_team_id: opponent_team.id,
      #meeting_point_id: 1,
      start_at: Timex.Date.local,
      home_match: false
    }
  end

  def factory(:news) do
    %ClubHomepage.News{
      subject: sequence(:subject, &"News Subject #{&1}"),
      body: sequence(:body, &"This is the news message #{&1}."),
      public: true
    }
  end

  def factory(:meeting_point) do
    address = create(:address)
    %ClubHomepage.MeetingPoint{
      address_id: address.id,
      name: sequence(:name, &"Meeting Point #{&1}")
    }
  end

  def factory(:opponent_team) do
    %ClubHomepage.OpponentTeam{
      name: sequence(:name, &"Opponent Team #{&1}")
    }
  end

  def factory(:permalink) do
    team = create(:team)
    %ClubHomepage.Permalink{
      source_path: sequence(:source_path, &"old-#{&1}"),
      destination_path: team.slug
    }
  end

  def factory(:season) do
    %{year: year} = Timex.Date.now
    %ClubHomepage.Season{
      name: sequence(:name, &"#{year}-#{year + &1}")
    }
  end

  def factory(:secret) do
    %ClubHomepage.Secret{
      key: SecureRandom.urlsafe_base64,
      expires_at: Timex.Date.local |> Timex.Date.add(Timex.Time.to_timestamp(7, :days))
    }
  end

  def factory(:team) do
    %ClubHomepage.Team{
      name: sequence(:name, &"This is my    team #{&1} without ß in the name."),
      slug: sequence(:slug, &"this-is-my-team-#{&1}-without-ss-in-the-name")
    }
  end

  def factory(:unregistered_user) do
    %ClubHomepage.User{
      email: sequence(:email, &"mail-#{&1}@example.de"),
      name: sequence(:login, &"my name #{&1}"),
    }
  end

  def factory(:user) do
    %ClubHomepage.User{
      birthday: Timex.Date.from({1988, 4, 17}, :local), 
      email: sequence(:email, &"mail-#{&1}@example.de"),
      login: sequence(:login, &"my_login-#{&1}"), 
      name: sequence(:login, &"my name #{&1}"), 
      password_hash: Comeonin.Bcrypt.hashpwsalt("my password"),
      active: true
    }
  end
end
