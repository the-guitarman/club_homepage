defmodule ClubHomepage.SponsorImage do
  use ClubHomepage.Web, :model
  use Arc.Ecto.Schema

  schema "sponsor_images" do
    field :name, :string
    field :attachment, ClubHomepage.Web.SponsorUploader.Type

    timestamps([type: :utc_datetime])
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name])
    |> cast_attachments(params, [:attachment])
    |> validate_required([:name, :attachment])
  end
end
