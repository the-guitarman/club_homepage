defmodule ClubHomepage.SEO.Plug do
  import Plug.Conn

  def put_seo(%{private: %{phoenix_action: action}} = conn, settings) do
    settings = settings[action] || []

    conn
    |> assign(:title, settings[:title])
    |> assign(:meta, settings[:meta])
  end
end
