defmodule SllackWeb.ChatRoomLive.ThreadComponent do
  use SllackWeb, :live_component

  import SllackWeb.ChatComponents

  def render(assigns) do
    ~H"""
    <div class="flex flex-col shrink-0 w-1/4 max-w-xs border-l border-slate-300 bg-slate-100">
      <div class="flex items-center shrink-0 h-16 border-b border-slate-300 px-4">
        <div>
          <h2 class="text-sm font-semibold leading-none">Thread</h2>
          <a class="text-xs leading-none" href="#">#{@room.name}</a>
        </div>
        <button
          class="flex items-center justify-center w-6 h-6 rounded hover:bg-gray-300 ml-auto"
          phx-click="close-thread"
        >
          <.icon name="hero-x-mark" class="w-5 h-5" />
        </button>
      </div>
      <div class="flex flex-col grow overflow-auto">
        <div class="border-b border-slate-300">
          <.message
            message={@message}
            dom_id="thread-message"
            current_user={@current_user}
            timezone={@timezone}
            in_thread?={true}
          />
        </div>
        <div id="thread-replies" phx-update="stream">
          <.message
            :for={{dom_id, reply} <- @streams.replies}
            current_user={@current_user}
            dom_id={dom_id}
            message={reply}
            in_thread?
            timezone={@timezone}
          />
        </div>
      </div>
    </div>
    """
  end

  # As mount/3 doesn't have access to the assigns that are passed to the component,
  # we initialize the stream in update/2.
  def update(assigns, socket) do
    socket
    |> stream(:replies, assigns.message.replies, reset: true)
    |> assign(assigns)
    |> ok()
  end
end
