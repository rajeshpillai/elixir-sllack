defmodule SllackWeb.ChatRoomLive do
  use SllackWeb, :live_view

  alias Sllack.Chat.Room
  alias Sllack.Chat
  alias Sllack.Chat.Message
  alias Sllack.Accounts.User

  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()
    timezone = get_connect_params(socket)["timezone"] || "UTC"
    {:ok, assign(socket, rooms: rooms, timezone: timezone)}
  end

  def handle_params(params, _uri, socket) do
    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Chat.get_room!(id)

        :error ->
          List.first(socket.assigns.rooms)
      end

    # {:noreply, assign(socket, room: room, hide_topic?: false, page_title: "#" <> room.name)}
    messages = Chat.list_messages_in_room(room)

    {:noreply,
     socket
      |> assign(
        room: room,
        hide_topic?: false,
        page_title: "#" <> room.name
      )
      |> stream(:messages, messages, reset: true)
      |> assign_message_form(Chat.change_message(%Message{}))
    }

  end

  defp assign_message_form(socket, changeset) do
    assign(socket, :new_message_form, to_form(changeset))
  end

  def handle_event("delete-message", %{"id" => id}, socket) do
    IO.puts("Delete message: #{id}")
    %{current_scope: current_scope} = socket.assigns
    current_user = current_scope.user
    case Chat.delete_message_by_id(id, current_user) do
      {:ok, _message} ->
        {:noreply, stream_delete(socket, :messages, id)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("submit-message", %{"message" => message_params}, socket) do
    IO.puts("Submit message: ")
    IO.inspect(socket.assigns)
    %{current_scope: current_scope, room: room} = socket.assigns
    current_user = current_scope.user
    socket =
      case Chat.create_message(room, message_params, current_user) do
        {:ok, message} ->
          socket
          |> stream_insert(:messages, message)
          |> assign_message_form(Chat.change_message(%Message{}))

        {:error, changeset} ->
          assign_message_form(socket, changeset)
      end

    {:noreply, socket}
  end

  def handle_event("validate-message", %{"message" => message_params}, socket) do
    changeset = Chat.change_message(%Message{}, message_params)

    {:noreply, assign_message_form(socket, changeset)}
  end

  def handle_event("toggle-topic", _params, socket) do
    # {:noreply, assign(socket, :hide_topic?, !socket.assigns.hide_topic?)}
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
    <div class="flex flex-col shrink-0 w-64 bg-slate-100">
      <div class="flex justify-between items-center shrink-0 h-16 border-b border-slate-300 px-4">
        <div class="flex flex-col gap-1.5">
          <h1 class="text-lg font-bold text-gray-800">
            Sllack
          </h1>
        </div>
      </div>
      <div class="mt-4 overflow-auto">
        <div class="flex items-center h-8 px-3">
          <span class="ml-2 leading-none font-medium text-sm">Rooms</span>
        </div>
        <div id="rooms-list">
          <.room_link :for={room <- @rooms} room={room} active={room.id == @room.id} />
        </div>
      </div>
    </div>
    <div class="flex flex-col grow shadow-lg">
      <div class="flex justify-between items-center shrink-0 h-16 bg-white border-b border-slate-300 px-4">
        <div class="flex flex-col gap-1.5">
          <h1 class="text-sm font-bold leading-none">
            #{@room.name}
            <.link class="font-normal text-xs text-blue-600 hover:text-blue-700"
              navigate={~p"/rooms/#{@room}/edit"}>
              Edit
            </.link>
          </h1>
          <div
            class={["text-xs leading-none h-3.5", @hide_topic? && "text-slate-600"]}
            phx-click="toggle-topic"
          >
            <%= if @hide_topic? do %>
              [Topic hidden]
            <% else %>
              {@room.topic}
            <% end %>
          </div>
        </div>
      </div>
        <ul class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
          <%= if @current_scope do %>
            <li>
              {username(@current_scope.user)}
            </li>
            <li>
              <.link href={~p"/users/settings"}>Settings</.link>
            </li>
            <li>
              <.link href={~p"/users/log-out"} method="delete">Log out</.link>
            </li>
          <% else %>
            <li>
              <.link href={~p"/users/register"}>Register</.link>
            </li>
            <li>
              <.link href={~p"/users/log-in"}>Log in</.link>
            </li>
          <% end %>
        </ul>
        <div id="room-messages" class="flex flex-col grow overflow-auto" phx-update="stream">
          <.message
            :for={{dom_id, message} <- @streams.messages}
            current_user={@current_scope && @current_scope.user}
            message={message}
            dom_id={dom_id}
            timezone={@timezone}
         } />
        </div>
        <div class="h-12 bg-white px-4 pb-4">
        <.form
          id="new-message-form"
          for={@new_message_form}
          phx-change="validate-message"
          phx-submit="submit-message"
          class="flex items-center border-2 border-slate-300 rounded-sm p-1 border-b-0"
        >
          <textarea
            class="grow text-sm px-3 border-l border-slate-300 mx-1 resize-none"
            cols=""
            id="chat-message-textarea"
            name={@new_message_form[:body].name}
            placeholder={"Message ##{@room.name}"}
            phx-debounce
            rows="1"
          >{Phoenix.HTML.Form.normalize_value("textarea", @new_message_form[:body].value)}</textarea>
          <button class="shrink flex items-center justify-center h-6 w-6 rounded hover:bg-slate-200">
            <.icon name="hero-paper-airplane" class="h-4 w-4" />
          </button>
        </.form>
      </div>
    </div>
    </Layouts.app>

    """
  end

  attr :current_user, User, required: true
  attr :dom_id, :string, required: true
  attr :message, Message, required: true
  attr :timezone, :string, required: true


  defp message(assigns) do
    ~H"""
    <div id={@dom_id} class="relative flex px-4 py-3">
      <button
        :if={@current_user.id == @message.user_id}
        class="absolute top-4 right-4 text-red-500 hover:text-red-800 cursor-pointer"
        data-confirm="Are you sure?"
        phx-click="delete-message"
        phx-value-id={@message.id}
      >
      <.icon name="hero-trash" class="h-4 w-4" />
      </button>
      <div class="h-10 w-10 rounded shrink-0 bg-slate-300"></div>
      <div class="ml-2">
        <div class="-mt-1">
          <.link class="text-sm font-semibold hover:underline">
            <span>{username(@message.user)}</span>
          </.link>
          <span :if={@timezone} class="ml-1 text-xs text-gray-500">
            {message_timestamp(@message, @timezone)}
          </span>
          <p class="text-sm">{@message.body}</p>
        </div>
      </div>
    </div>
    """
  end

  defp message_timestamp(message, timezone) do
    message.inserted_at
      |> Timex.Timezone.convert(timezone)
      |> Timex.format!("%-l:%M %p", :strftime)
  end

  defp username(user) do
    user.email
    |> String.split("@")
    |> List.first()
    |> String.capitalize()
  end

  attr :active, :boolean, required: true
  attr :room, Room, required: true

  defp room_link(assigns) do
    ~H"""
    <.link
      class={[
        "flex items-center h-8 text-sm pl-8 pr-3",
        (@active && "bg-slate-300") || "hover:bg-slate-300"
      ]}
      navigate={~p"/rooms/#{@room}"}
    >
      <.icon name="hero-hashtag" class="h-4 w-4" />
      <span class={["ml-2 leading-none", @active && "font-bold"]}>
        {@room.name}
      </span>
    </.link>
    """
  end

end
