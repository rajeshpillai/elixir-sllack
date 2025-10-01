defmodule SllackWeb.RoomController do
  use SllackWeb, :controller

  alias Sllack.Chat

  def redirect_to_first(conn, _params) do
    user = conn.assigns.current_scope.user

    path = case Chat.list_joined_rooms(user) do
      [] -> ~p"/rooms"
      [first | _] -> ~p"/rooms/#{first.id}"
    end
    redirect(conn, to: path)
  end


end
