defmodule ClubHomepage.PageController do
  use ClubHomepage.Web, :controller

  def index(conn, _params) do
    teams = ClubHomepage.Repo.all(ClubHomepage.Team)
    render conn, "index.html", teams: teams
  end

  def chronicle(conn, _params) do
    render conn, "chronicle.html"
  end

  def contact(conn, _params) do
    render conn, "contact.html"
  end

  def impressum(conn, _params) do
    render conn, "registration_information.html"
  end

  def sponsors(conn, _params) do
    render conn, "sponsors.html"
  end

  def the_club(conn, _params) do
    render conn, "the_club.html"
  end
end
