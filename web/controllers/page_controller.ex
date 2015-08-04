defmodule Cream.PageController do
  use Cream.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
