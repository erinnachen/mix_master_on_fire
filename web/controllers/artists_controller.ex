defmodule MixMaster.ArtistsController do
  use MixMaster.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    changeset = Artist.changeset(%Artist{})
    render conn, "new.html"
  end
end
