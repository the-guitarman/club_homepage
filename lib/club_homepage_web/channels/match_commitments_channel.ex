defmodule ClubHomepage.Web.MatchCommitmentsChannel do
  use ClubHomepage.Web, :channel

  alias ClubHomepage.Repo
  alias ClubHomepage.MatchCommitment

  def join("match-commitments:" <> user_id, _payload, socket) do
    user_id = String.to_integer(user_id)
    {:ok, assign(socket, :user_id, user_id)}
  end

  def handle_in("participation:yes", %{"match_id" => match_id}, socket) do
    state = set_match_commitment(socket.assigns.user_id, match_id, 1)
    result =  %{:user_id => socket.assigns.user_id, :match_id => match_id}
    get_reply(socket, state, result)
  end

  def handle_in("participation:dont-no", %{"match_id" => match_id}, socket) do
    state = set_match_commitment(socket.assigns.user_id, match_id, 0)
    result =  %{user_id: socket.assigns.user_id, match_id: match_id}
    get_reply(socket, state, result)
  end

  def handle_in("participation:no", %{"match_id" => match_id}, socket) do
    state = set_match_commitment(socket.assigns.user_id, match_id, -1)
    result =  %{user_id: socket.assigns.user_id, match_id: match_id}
    get_reply(socket, state, result)
  end

  defp get_reply(socket, state, payload) do
    {:reply, {state, payload}, socket}
  end

  defp set_match_commitment(user_id, match_id, commitment) do
    case find_match_commitment(user_id, match_id) do
      nil -> create_match_commitment(user_id, match_id, commitment)
      match_commitment -> update_match_commitment(match_commitment, commitment)
    end
  end

  defp find_match_commitment(user_id, match_id) do
    Repo.get_by(MatchCommitment, user_id: user_id, match_id: match_id)
  end

  defp create_match_commitment(user_id, match_id, commitment) do
    changeset = MatchCommitment.changeset(%MatchCommitment{}, %{user_id: user_id, match_id: match_id, commitment: commitment})
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
