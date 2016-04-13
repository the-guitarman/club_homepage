defmodule ClubHomepage.AddressController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Address

  plug :is_match_editor?
  plug :scrub_params, "address" when action in [:create, :update]

  def index(conn, _params) do
    addresses = Repo.all(Address)
    render(conn, "index.html", addresses: addresses)
  end

  def new(conn, _params) do
    changeset = Address.changeset(%Address{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"address" => address_params}) do
    changeset = Address.changeset(%Address{}, address_params)

    case Repo.insert(changeset) do
      {:ok, address} ->
        conn
        |> put_flash(:info, "Address created successfully.")
        |> redirect(to: address_path(conn, :index) <> "#address-#{address.id}")
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    address = Repo.get!(Address, id)
    render(conn, "show.html", address: address)
  end

  def edit(conn, %{"id" => id}) do
    address = Repo.get!(Address, id)
    changeset = Address.changeset(address)
    render(conn, "edit.html", address: address, changeset: changeset)
  end

  def update(conn, %{"id" => id, "address" => address_params}) do
    address = Repo.get!(Address, id)
    changeset = Address.changeset(address, address_params)

    case Repo.update(changeset) do
      {:ok, address} ->
        conn
        |> put_flash(:info, "Address updated successfully.")
        |> redirect(to: address_path(conn, :index) <> "#address-#{address.id}")
      {:error, changeset} ->
        render(conn, "edit.html", address: address, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    address = Repo.get!(Address, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(address)

    conn
    |> put_flash(:info, "Address deleted successfully.")
    |> redirect(to: address_path(conn, :index))
  end
end
