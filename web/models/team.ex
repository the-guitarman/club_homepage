defmodule ClubHomepage.Team do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  schema "teams" do
    field :name, :string
    field :rewrite, :string

    #has_many :matches, ClubHomepage.Match, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(rewrite)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ModelValidator.validate_uniqueness(:name, message: "ist bereits vergeben")
    |> ClubHomepage.RewriteGenerator.run(:name, :rewrite)
    |> ModelValidator.validate_uniqueness(:rewrite, message: "ist bereits vergeben")
  end
end
