defmodule ClubHomepage.Team do
  use ClubHomepage.Web, :model

  #alias ClubHomepage.Web.ModelValidator

  schema "teams" do
    field :name, :string
    field :order, :integer
    field :slug, :string
    field :fussball_de_team_url, :string
    field :fussball_de_team_rewrite, :string
    field :fussball_de_team_id, :string
    field :fussball_de_show_next_matches, :boolean
    field :fussball_de_last_next_matches_check_at, Timex.Ecto.DateTime
    field :fussball_de_show_current_table, :boolean
    field :current_table_html, :string
    field :current_table_html_at, Timex.Ecto.DateTime

    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all
    belongs_to :competition, ClubHomepage.Competition

    timestamps()
  end

  @cast_fields ~w(competition_id name order slug fussball_de_team_url fussball_de_team_rewrite fussball_de_team_id fussball_de_show_next_matches fussball_de_last_next_matches_check_at fussball_de_show_current_table current_table_html current_table_html_at)
  @required_fields [:competition_id, :name]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:competition_id)
    |> unique_constraint(:name)
    |> ClubHomepage.Web.SlugGenerator.run(:name, :slug)
    |> unique_constraint(:slug)
    |> ClubHomepage.Web.FussballDeTeamUrlChecker.run(:fussball_de_team_url, :fussball_de_team_rewrite, :fussball_de_team_id)
  end
end

#defimpl Phoenix.Param, for: ClubHomepage.Team do
#  def to_param(%{slug: slug}) do
#    slug
#  end
#end
