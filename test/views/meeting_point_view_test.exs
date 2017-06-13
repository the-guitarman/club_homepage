defmodule ClubHomepage.MeetingPointViewTest do
  use ClubHomepage.Web.ConnCase, async: true

#  import Phoenix.HTML, only: [safe_to_string: 1]
  import ClubHomepage.Factory

#  alias ClubHomepage.MeetingPoint
  alias ClubHomepage.MeetingPointView
  alias ClubHomepage.Repo

  test "full address of meeting point" do
    meeting_point = insert(:meeting_point)

    address =
      MeetingPointView.full_address(meeting_point)
      #|> safe_to_string()

    assert address == ""

    address = insert(:address)
    meeting_point =
      insert(:meeting_point, address_id: address.id)
      |> Repo.preload([:address])
    #meeting_point = Repo.get!(MeetingPoint, meeting_point.id)

    address =
      MeetingPointView.full_address(meeting_point)
      #|> safe_to_string()

    assert address == "Street 1, 11111 City District 1"
  end
end
