defmodule SllackWeb.ChatRoomLive do
  use SllackWeb, :live_view

  def render(assigns) do
    ~H"""
    <p>Welcome to the chat room!</p>
    """
  end
end
