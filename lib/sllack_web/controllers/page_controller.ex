defmodule SllackWeb.PageController do
  use SllackWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
