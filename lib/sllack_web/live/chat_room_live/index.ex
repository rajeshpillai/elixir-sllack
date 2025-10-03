defmodule SllackWeb.ChatRoomLive.Index do
  use SllackWeb, :live_view

  alias Sllack.Chat

  def render(assigns) do
    ~H"""
    <main class="flex-1 p-6 max-w-4xl mx-auto">
      <div class="mb-4">
        <h1 class="text-xl font-semibold">{@page_title}</h1>
      </div>
      <div class="bg-slate-50 border rounded">
        <div id="rooms" class="divide-y" phx-update="stream">
          <div
            :for={{id, {room, joined?}} <- @streams.rooms}
            class="cursor-pointer p-4 flex justify-between items-center group first:rounded-t last:rounded-b"
            id={id}
            navigate={~p"/rooms/#{room}"}
            phx-click={open_room(room)}
            phx-keydown={open_room(room)}
            phx-key="Enter"
            tabindex="0"
          >
            <div>
              <div class="font-medium mb-1">
                #{room.name}
                <span class="mx-1 text-gray-500 font-light text-sm hidden group-hover:inline group-focus:inline">
                  View room
                </span>
              </div>
              <div class="text-gray-500 text-sm">
                <% joined? = Chat.joined?(room, @current_scope.user) %>
                <%= if joined? do %>
                  <span class="text-green-600 font-bold">
                    Joined
                  </span>
                <% end %>

                <%= if joined? and room.topic do %>
                  <span class="mx-1">|</span>
                <% end %>
                <%= if room.topic do %>
                  {room.topic}
                <% end %>
              </div>
            </div>
            <button
              class="opacity-0 group-hover:opacity-100 group-focus:opacity-100 focus:opacity-100 bg-white hover:bg-gray-100 border border-gray-400 text-gray-700 px-3 py-1.5 w-24 rounded-sm font-bold"
              phx-click="toggle-room-membership"
              phx-value-id={room.id}>
              <%= if joined? do %>
                Leave
              <% else %>
                Join
              <% end %>
            </button>
          </div>
        </div>
      </div>
    </main>
    """
  end

  defp open_room(room) do
    JS.navigate(~p"/rooms/#{room}")
  end

  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms_with_joined(socket.assigns.current_scope.user)

    socket =
      socket
      |> assign(page_title: "Chat Rooms")
      |> stream_configure(:rooms, dom_id: fn {room, _} -> "rooms-#{room.id}" end)
      |> stream(:rooms, rooms)
    {:ok, socket}
  end

  def handle_event("toggle-room-membership", %{"id" => id}, socket) do
    {room, joined?} =
      id
      |> Chat.get_room!()
      |> Chat.toggle_room_membership(socket.assigns.current_scope.user)

    {:noreply, stream_insert(socket, :rooms, {room, joined?})}
  end

end
