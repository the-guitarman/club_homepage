defmodule ClubHomepage.Competition do
  use ClubHomepageWeb, :model

  #alias ClubHomepageWeb.ModelValidator

  schema "competitions" do
    field :name, :string
    field :matches_need_decition, :boolean

    has_many :teams, ClubHomepage.Team#, on_delete: :delete_all
    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all

    timestamps([type: :utc_datetime])
  end

  @cast_fields ~w(name matches_need_decition)a
  @required_fields [:name, :matches_need_decition]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
    #|> ModelValidator.validate_uniqueness(:name)
  end
end
