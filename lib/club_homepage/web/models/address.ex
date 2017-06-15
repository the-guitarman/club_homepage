defmodule ClubHomepage.Address do
  use ClubHomepage.Web, :model

  schema "addresses" do
    field :district, :string
    field :street, :string
    field :zip_code, :string
    field :city, :string
    field :latitude, :float
    field :longitude, :float

    has_many :meeting_points, ClubHomepage.MeetingPoint#, on_delete: :delete_all
    has_one :opponent_team, ClubHomepage.OpponentTeam#, on_delete: :delete_all

    timestamps()
  end

  @cast_fields ~w(street zip_code city district latitude longitude)
  @required_fields [:street, :zip_code, :city]

  def required_field?(field) when is_binary(field) do
    Enum.member?(@required_fields, field)
  end
  def required_field?(field) when is_atom(field) do
    required_field?(Atom.to_string(field))
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:zip_code, min: 5, message: "ist zu kurz (min. 5 Zeichen)")
    |> validate_length(:zip_code, max: 5, message: "ist zu lang (max. 5 Zeichen)")
    |> validate_format(:zip_code, ~r/\A[0-9]+\z/i, message: "enthält ungültige Zeichen (gültig: 0-9)")
    |> geolocate
  end

  defp geolocate(changeset) do
    case changeset.valid? do
      false -> changeset
      true  -> set_geolocation_coords(changeset)
    end
  end

  defp set_geolocation_coords(changeset) do
    address = get_value_from_changeset(changeset, :street) <> ", " <>
      get_value_from_changeset(changeset, :zip_code) <> " " <>
      get_value_from_changeset(changeset, :city)
    address = 
      case get_value_from_changeset(changeset, :district) do
        nil -> address
        ""  -> address
        district -> address <> ", " <> district
      end
    case Geocoder.call(address) do
      {:error, _}   -> changeset
      {:ok, coords} ->
        changeset
        |> Ecto.Changeset.put_change(:latitude, coords.lat)
        |> Ecto.Changeset.put_change(:longitude, coords.lon)
    end
  end

  defp get_value_from_changeset(changeset, key) do
    case changeset.changes[key] do
      nil ->
        {:ok, value} = Map.fetch(changeset.data, key)
        value
      value -> value
    end
  end
end
