const ChatMessageTextarea = {
  mounted() {
    console.log("Hook mounted: ChatMessageTextarea", this.el.getAttribute("id"));

    this.el.addEventListener("keydown", (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
            e.preventDefault();
            this.el.form.requestSubmit();
        }
    });
  },
};

export default ChatMessageTextarea;