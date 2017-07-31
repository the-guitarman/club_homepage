defmodule ClubHomepage.PaymentListDebitorHistoryRecord do
  use ClubHomepage.Web, :model

  schema "payment_list_debitor_history_records" do
    field :old_number_of_units, :integer
    field :new_number_of_units, :integer
    
    belongs_to :payment_list_debitor, ClubHomepage.PaymentListDebitor
    belongs_to :editor, ClubHomepage.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:payment_list_debitor_id, :editor_id, :old_number_of_units, :new_number_of_units])
    |> validate_required([:payment_list_debitor_id, :editor_id, :old_number_of_units, :new_number_of_units])
    |> foreign_key_constraint(:payment_list_id)
    |> foreign_key_constraint(:editor_id)
    |> validate_number(:old_number_of_units, greater_than_or_equal_to: 0)
    |> validate_number(:new_number_of_units, greater_than_or_equal_to: 0)
  end
end
