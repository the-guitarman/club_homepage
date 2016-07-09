defmodule ClubHomepage.Team do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  schema "teams" do
    field :name, :string
    field :slug, :string

    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all
    belongs_to :competition, ClubHomepage.Competition

    timestamps
  end

  @required_fields ~w(competition_id name)
  @optional_fields ~w(slug)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:competition_id)
    |> unique_constraint(:name)
    |> ClubHomepage.SlugGenerator.run(:name, :slug)
    |> unique_constraint(:slug)
  end
end

#defimpl Phoenix.Param, for: ClubHomepage.Team do
#  def to_param(%{slug: slug}) do
#    slug
#  end
#end
