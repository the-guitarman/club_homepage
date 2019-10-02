defmodule ClubHomepage.Season do
  use ClubHomepageWeb, :club_homepage_model
  use ClubHomepageWeb, :model

  schema "seasons" do
    field :name, :string

    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all

    timestamps([type: :utc_datetime])
  end

  @cast_fields ~w(name)a
  @required_fields [:name]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_format(:name, ~r/\A20\d\d-20\d\d\z/i)
  end
end
