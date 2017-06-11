defmodule ClubHomepage.Web.TeamChatMessageController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.TeamChatMessage

  plug :is_team_editor?

  def index(conn, _params) do
    team_chat_messages = Repo.all(TeamChatMessage)
    render(conn, "index.html", team_chat_messages: team_chat_messages)
  end

  def delete(conn, %{"id" => id}) do
    team_chat_message = Repo.get!(TeamChatMessage, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(team_chat_message)

    conn
    |> put_flash(:info, "Team chat message deleted successfully.")
    |> redirect(to: team_chat_message_path(conn, :index))
  end
end
