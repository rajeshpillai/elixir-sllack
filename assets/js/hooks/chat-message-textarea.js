const ChatMessageTextarea = {
  mounted() {
    console.log("Hook mounted: ChatMessageTextarea", this.el.getAttribute("id"));

    this.el.addEventListener("keydown", (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          const form = this.el.closest("form");
          // this.el.form.requestSubmit();

          // TODO;  ensure you use this.el.  If you use form.dispatchEvent, for change then you will get the message
          // "Uncaught Error: form events require the input to be inside a form"
          this.el.dispatchEvent(new Event("change", {bubbles: true, cancelable: true}));
          form.dispatchEvent(new Event("submit", {bubbles: true, cancelable: true}));
          this.el.value = "";
        }
    });
  },
};

export default ChatMessageTextarea;