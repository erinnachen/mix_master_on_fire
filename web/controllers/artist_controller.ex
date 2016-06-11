defmodule MixMaster.ArtistController do
  use MixMaster.Web, :controller
  alias MixMaster.Artist

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    changeset = Artist.changeset(%Artist{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params) do
  end
end
