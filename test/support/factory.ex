defmodule ClubHomepage.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: ClubHomepage.Repo

  # without Ecto
  #use ExMachina

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

  def factory(:unregistered_user) do
    %ClubHomepage.User{
      email: sequence(:email, &"mail-#{&1}@example.de"),
      name: sequence(:login, &"my name #{&1}"),
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
      name: "This is my    team without ß in the name.",
      rewrite: "this-is-my-team-without-ss-in-the-name"
    }
  end
end
