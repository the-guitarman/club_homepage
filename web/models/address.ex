defmodule ClubHomepage.Address do
  use ClubHomepage.Web, :model

  schema "addresses" do
    field :district, :string
    field :street, :string
    field :zip_code, :string
    field :city, :string    
    field :latitude, :float 
    field :longitude, :float

    timestamps
  end

  @required_fields ~w(street zip_code city)
  @optional_fields ~w(district latitude longitude)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:login, min: 5, message: "ist zu kurz (min. 5 Zeichen)")
    |> validate_length(:login, max: 5, message: "ist zu lang (max. 5 Zeichen)")
    |> validate_format(:zip_code, ~r/\A[0-9]+\z/i, message: "enthält ungültige Zeichen (gültig: 0-9)")
  end
end
