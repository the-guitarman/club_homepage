defmodule ClubHomepage.JavascriptLocalization do
  @moduledoc """
  This module holds calculations around birthdays.
  """

  # import Plug.Conn
  import ClubHomepage.Gettext
  import ClubHomepage.Localization

  # def init(_opts) do
  #   nil
  # end

  # def call(conn, _) do
  #   assign(conn, :javascript_localization, run)
  # end

  @doc """
  Returns the javascript localization configuration.
  """
  @spec run() :: Map
  def run() do
    %{locale: locale(), date_format: date_format()}
  end

  defp locale do
    Application.get_env(:club_homepage, ClubHomepage.Endpoint)[:locale]
    |> String.downcase
  end
end
