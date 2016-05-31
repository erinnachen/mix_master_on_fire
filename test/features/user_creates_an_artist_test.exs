defmodule MixMaster.UserCreatesArtistTest do
  use MixMaster.ConnCase

  use Hound.Helpers

  hound_session

  test "GET /" do
    navigate_to "/"
    assert page_source =~ "Welcome to Phoenix"
  end

  #
  # test "User submits a new artist", %{conn: conn} do
  #   As a user
  #   When I visit the artists index
  #   And I click "New artist"
  #   And I fill in the name
  #   And I fill in an image path
  #   And I click "Create Artist"
  #   Then I should see the artist name and image on the page
  #
  #   conn = get conn, "/artists"
  #   # artist_name       = "Bob Marley"
  #   # artist_image_path = "http://cps-static.rovicorp.com/3/JPG_400/MI0003/146/MI0003146038.jpg"
  #   #
  #   # visit artists_path
  #   # click_on "New artist"
  #   # fill_in "artist_name", with: artist_name
  #   # fill_in "artist_image_path", with: artist_image_path
  #   # click_on "Create Artist"
  #   #
  #   # expect(page).to have_content artist_name
  #   # expect(page).to have_css("img[src=\"#{artist_image_path}\"]")
  #   assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  # end
end
