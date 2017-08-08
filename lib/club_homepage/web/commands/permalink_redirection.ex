defmodule ClubHomepage.Web.PermalinkRedirection do
  @moduledoc """
  Checks wether requested paths needs to be redirected.
  """

  import Phoenix.Controller
  import Plug.Conn

  alias ClubHomepage.Permalink
  alias ClubHomepage.Repo

  @doc false
  def init(opts) do
    Keyword.fetch!(opts, :path_prefixes)
  end

  @doc false
  def call(conn, path_prefixes) do
    case String.starts_with?(conn.request_path, clean_path_prefixes(path_prefixes)) do
      true -> find_permalink(conn)
      false -> conn
    end
  end

  defp find_permalink(conn) do
    case Repo.get_by(Permalink, source_path: conn.request_path) do
      nil -> conn
      permalink -> 
        conn
        |> put_status(301)
        |> redirect(to: permalink.destination_path)
        |> halt()
    end
  end

  defp clean_path_prefixes(prefixes) do
    prefixes
    |> Enum.map(fn(p) -> clean_path_prefix(p) end)
  end

  defp clean_path_prefix(prefix) when is_atom(prefix) do
    clean_path_prefix(Atom.to_string(prefix))
  end
  defp clean_path_prefix(prefix) when is_bitstring(prefix) do
    prefix
    |> clean_slashes
  end

  defp clean_slashes(text) do
    without_trailing_slashes = Regex.replace(~r{^/|/$}, text, "")
    without_double_slashes = Regex.replace(~r{//}, without_trailing_slashes, "/")
    "/#{without_double_slashes}/"
  end
end
