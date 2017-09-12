defmodule ClubHomepage.Web.UserSocket do
  use Phoenix.Socket

  @max_age 2 * 7 * 24 * 60 * 60

  ## Channels
  # channel "rooms:*", ClubHomepage.RoomChannel
  channel "match-timelines:*", ClubHomepage.Web.MatchTimelineChannel
  channel "team-chats:*", ClubHomepage.Web.TeamChatChannel
  channel "team-chat-badges:*", ClubHomepage.Web.TeamChatBadgeChannel
  channel "payment-lists:*", ClubHomepage.Web.PaymentListChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  # def connect(_params, socket) do
  #   {:ok, socket}
  # end
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} ->
        user = ClubHomepage.Repo.get!(ClubHomepage.User, user_id)
        {:ok, assign(socket, :current_user, user)}
      {:error, _reason} -> :error
    end
  end
  def connect(_params, _socket), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ClubHomepage.Web.Endpoint.broadcast("users_socket:" <> user.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # def id(_socket), do: nil
  def id(socket) do
    "users_socket: #{socket.assigns.current_user.id}"
  end
end
