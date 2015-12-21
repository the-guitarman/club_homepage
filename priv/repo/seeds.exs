# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ClubHomepage.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ClubHomepage.Repo
alias ClubHomepage.User
alias ClubHomepage.Team

# First user is an administrator.
unless Repo.get_by(User, login: "guitarman") do
  #{:ok, date} = Ecto.Date.cast("1978-10-13")
  date = Timex.Date.from({1978, 10, 13}, :local)
  changeset = User.registration_changeset(%User{}, %{
    active: true, 
    login: "guitarman", password: "basti@tsv",  
    name: "Sebastian H.", email: "shendygk@freenet.de", 
    birthday: date, roles: "member administrator"
  })
  Repo.insert(changeset)
end

# Teams
club_name = "TSV Einheit Claußnitz"
club_rewrite = "tsv-einheit-claussnitz"
unless Repo.get_by(Team, rewrite: "#{club_rewrite}-herren") do
  changeset = Team.changeset(%Team{}, %{name: "#{club_name} Herren"})
  Repo.insert(changeset)
end
unless Repo.get_by(Team, rewrite: "#{club_rewrite}-herren-2") do
  changeset = Team.changeset(%Team{}, %{name: "#{club_name} Herren 2"})
  Repo.insert(changeset)
end


#mix phoenix.gen.html Video videos user_id:references:users url:string title:string description:text