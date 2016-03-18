defmodule ClubHomepage.Competition do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  schema "competitions" do
    field :name, :string

    has_many :teams, ClubHomepage.Team, on_delete: :delete_all
    has_many :matches, ClubHomepage.Match, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ModelValidator.validate_uniqueness(:name)
  end
end
