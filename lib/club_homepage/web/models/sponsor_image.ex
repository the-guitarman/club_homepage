defmodule ClubHomepage.SponsorImage do
  use ClubHomepage.Web, :model
  use Arc.Ecto.Schema

  schema "sponsor_images" do
    field :name, :string
    field :attachment, ClubHomepage.SponsorUploader.Type

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(Map.drop(params, [:attachment, "attachment"]), [:name])
    |> validate_required([:name])
  end

  def image_changeset(model, params \\ %{}) do
    model
    |> cast_attachments(params, [:attachment])
    |> validate_required([:attachment])
  end
end
