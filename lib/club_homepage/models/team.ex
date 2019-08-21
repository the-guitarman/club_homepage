defmodule ClubHomepage.Team do
  use ClubHomepageWeb, :model

  #alias ClubHomepageWeb.ModelValidator

  schema "teams" do
    field :name, :string
    field :order, :integer
    field :slug, :string
    field :fussball_de_team_url, :string
    field :fussball_de_team_rewrite, :string
    field :fussball_de_team_id, :string
    field :fussball_de_show_next_matches, :boolean
    field :fussball_de_last_next_matches_check_at, :utc_datetime
    field :fussball_de_show_current_table, :boolean
    field :current_table_html, :string
    field :current_table_html_at, :utc_datetime
    field :active, :boolean, default: true

    has_many :matches, ClubHomepage.Match#, on_delete: :delete_all
    belongs_to :competition, ClubHomepage.Competition

    timestamps([type: :utc_datetime])
  end

  @cast_fields ~w(competition_id name order slug fussball_de_team_url fussball_de_team_rewrite fussball_de_team_id fussball_de_show_next_matches fussball_de_last_next_matches_check_at fussball_de_show_current_table current_table_html current_table_html_at active)a
  @required_fields [:competition_id, :name, :active]

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
    |> ClubHomepageWeb.SlugGenerator.run(:name, :slug)
    |> unique_constraint(:slug)
    |> ClubHomepageWeb.FussballDeTeamUrlChecker.run(:fussball_de_team_url, :fussball_de_team_rewrite, :fussball_de_team_id)
  end
end

#defimpl Phoenix.Param, for: ClubHomepage.Team do
#  def to_param(%{slug: slug}) do
#    slug
#  end
#end
