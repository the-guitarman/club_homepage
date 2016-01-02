defmodule ClubHomepage.Address do
  use ClubHomepage.Web, :model

  schema "addresses" do
    field :district, :string
    field :street, :string
    field :zip_code, :string
    field :city, :string    
    field :latitude, :float 
    field :longitude, :float

    has_many :meeting_points, ClubHomepage.MeetingPoint, on_delete: :delete_all
    has_one :opponent_team, ClubHomepage.OpponentTeam, on_delete: :delete_all

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
    |> validate_length(:zip_code, min: 5, message: "ist zu kurz (min. 5 Zeichen)")
    |> validate_length(:zip_code, max: 5, message: "ist zu lang (max. 5 Zeichen)")
    |> validate_format(:zip_code, ~r/\A[0-9]+\z/i, message: "enthält ungültige Zeichen (gültig: 0-9)")
  end
end
