defmodule ClubHomepage.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: ClubHomepage.Repo

  # without Ecto
  #use ExMachina

  def factory(:address) do
    %ClubHomepage.Address{
      district: sequence(:district, &"District #{&1}")
    }
  end

  def factory(:match) do
    %ClubHomepage.Match{
      season_id: 1,
      team_id: 1,
      opponent_team_id: 1,
      meeting_point_id: 1,
      start_at: Timex.Date.local,
      home_match: false
    }
  end

  def factory(:meeting_point) do
    %ClubHomepage.MeetingPoint{
      address_id: 1,
      name: sequence(:name, &"Meeting Point #{&1}")
    }
  end

  def factory(:opponent_team) do
    %ClubHomepage.OpponentTeam{
      name: sequence(:name, &"Opponent Team #{&1}")
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
      rewrite: sequence(:rewrite, &"this-is-my-team-#{&1}-without-ss-in-the-name")
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
