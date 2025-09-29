defmodule SllackWeb.ChatRoomLive do
  use SllackWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Chat Room</h1>
    <p>Welcome to the chat room!</p>
    """
  end
end
