defmodule ClubHomepage.PaymentListDebitor do
  use ClubHomepage.Web, :model

  schema "payment_list_debitors" do
    field :number_of_units, :integer
    
    belongs_to :payment_list, ClubHomepage.PaymentList
    belongs_to :user, ClubHomepage.User

    has_one :payment_list_owner, through: [:payment_list, :user]
    has_one :payment_list_deputy, through: [:payment_list, :deputy]

    has_many :history_records, ClubHomepage.PaymentListDebitorHistoryRecord, on_delete: :delete_all, foreign_key: :payment_list_debitor_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:payment_list_id, :user_id, :number_of_units])
    |> validate_required([:payment_list_id, :user_id, :number_of_units])
    |> foreign_key_constraint(:payment_list_id)
    |> foreign_key_constraint(:user_id)
    |> validate_number(:number_of_units, greater_than_or_equal_to: 0)
  end
end
