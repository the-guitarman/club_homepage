defmodule ClubHomepage.Web.MatchCommitmentsChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.Repo
  alias ClubHomepage.MatchCommitment

  def join("match-commitments:" <> match_id, _payload, socket) do
    match_id = String.to_integer(match_id)
    {:ok, assign(socket, :match_id, match_id)}
  end

  def handle_in("participation:yes", %{"user_id" => user_id}, socket) do
    state = set_match_commitment(socket.assigns.match_id, user_id, 1)
    result =  %{:match_id => socket.assigns.match_id, :user_id => user_id}
    get_reply(socket, state, result)
  end

  def handle_in("participation:dont-no", %{"user_id" => user_id}, socket) do
    state = set_match_commitment(socket.assigns.match_id, user_id, 0)
    result =  %{match_id: socket.assigns.match_id, user_id: user_id}
    get_reply(socket, state, result)
  end

  def handle_in("participation:no", %{"user_id" => user_id}, socket) do
    state = set_match_commitment(socket.assigns.match_id, user_id, -1)
    result =  %{match_id: socket.assigns.match_id, user_id: user_id}
    get_reply(socket, state, result)
  end

  defp get_reply(socket, state, payload) do
    {:reply, {state, payload}, socket}
  end

  defp set_match_commitment(match_id, user_id, commitment) do
    case find_match_commitment(match_id, user_id) do
      nil -> create_match_commitment(match_id, user_id, commitment)
      match_commitment -> update_match_commitment(match_commitment, commitment)
    end
  end

  defp find_match_commitment(match_id, user_id) do
    Repo.get_by(MatchCommitment, match_id: match_id, user_id: user_id)
  end

  defp create_match_commitment(match_id, user_id, commitment) do
    changeset = MatchCommitment.changeset(%MatchCommitment{}, %{match_id: match_id, user_id: user_id, commitment: commitment})
    case Repo.insert(changeset) do
      {:ok, _match_commitment} -> :ok
      {:error, _changeset} -> :error
    end
  end

  defp update_match_commitment(match_commitment, commitment) do
    changeset = MatchCommitment.changeset(match_commitment, %{commitment: commitment})
    case Repo.update(changeset) do
      {:ok, _match_commitment} -> :ok
      {:error, _changeset} -> :error
    end
  end
end
