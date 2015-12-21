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
      password: Comeonin.Bcrypt.hashpwsalt("my password")
    }
  end

  def factory(:secret) do
    %ClubHomepage.Secret{}
  end

  def factory(:team) do
    %ClubHomepage.Team{
      name: "This is my    team without ß in the name.",
      rewrite: "this-is-my-team-without-ss-in-the-name"
    }
  end
end