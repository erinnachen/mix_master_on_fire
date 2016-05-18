defmodule MixMaster.PageController do
  use MixMaster.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
