# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sllack.Repo.insert!(%Sllack.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Slax.Repo.insert!(%Slax.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Sllack.Accounts
alias Sllack.Chat.Room
alias Sllack.Chat.Message
alias Sllack.Repo

names = [
  "Rajesh",
  "Ashish",
  "Jai",
  "Urvashi",
  "Chandra",
  "Hrishi",
  "Pritesh"
]

pw = "TheFellowship"

for name <- names do
  email = (name |> String.downcase()) <> "@tekacademy.com"
  Accounts.register_user(%{email: email, password: pw, password_confirmation: pw})
end

rajesh = Accounts.get_user_by_email("rajesh@tekacademy.com")
chandra = Accounts.get_user_by_email("chandra@tekacademy.com")
ashish = Accounts.get_user_by_email("ashish@tekacademy.com")

room = Repo.insert!(%Room{name: "council-of-coding", topic: "What to do with this ring?"})

for {user, message} <- [
      {rajesh,
       "Strangers from distant lands, friends of old. You have been summoned here to answer the threat of Mordor. Middle-Earth stands upon the brink of destruction. None can escape it. You will unite or you will fall. Each race is bound to this fate–this one doom."},
      {rajesh, "Bring forth the Ring, Frodo."},
      {ashish, "So it is true…"},
      {ashish,
       "It is a gift. A gift to the foes of Mordor. Why not use this Ring? Long has my father, the Steward of Gondor, kept the forces of Mordor at bay. By the blood of our people are your lands kept safe! Give Gondor the weapon of the Enemy. Let us use it against him!"},
      {chandra,
       "You cannot wield it! None of us can. The One Ring answers to Sauron alone. It has no other master."},
      {ashish, "And what would a ranger know of this matter?"}
    ] do
  Repo.insert!(%Message{user: user, room: room, body: message})
end
