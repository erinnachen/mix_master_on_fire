defmodule MixMaster.UserCreatesArtistTest do
  use MixMaster.ConnCase

  use Hound.Helpers

  hound_session

  test "User submits a new artist" do
    artist_name = "Bob Marley"
    artist_image_path = "http://cps-static.rovicorp.com/3/JPG_400/MI0003/146/MI0003146038.jpg"

    navigate_to "/artists"

    click({:link_text, "New artist"})
    fill_field({:name, "artist[name]"}, artist_name)
    fill_field({:name, "artist[image_path]"}, artist_image_path)
    click({:css, "[type=submit]"})

    assert page_source =~ artist_name
    assert find_element(:css,"img[src=\"#{artist_image_path}\"]")
  end
end
