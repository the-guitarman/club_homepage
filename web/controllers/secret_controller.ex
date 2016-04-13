defmodule ClubHomepage.SecretController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Secret

  plug :is_user_editor?
  plug :scrub_params, "secret" when action in [:update]

  def index(conn, _params) do
    secrets = Repo.all(Secret)
    render(conn, "index.html", secrets: secrets)
  end

  def new(conn, _params) do
    changeset = Secret.changeset(%Secret{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, _) do
    changeset = Secret.changeset(%Secret{}, %{})

    case Repo.insert(changeset) do
      {:ok, _secret} ->
        conn
        |> put_flash(:info, "Das Secret wurde erfolgreich generiert.")
        |> redirect(to: secret_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    secret = Repo.get!(Secret, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(secret)

    conn
    |> put_flash(:info, "Das Secret wurde erfolgreich gelöscht.")
    |> redirect(to: secret_path(conn, :index))
  end
end
