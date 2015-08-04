defmodule Cream.ContactView do
  use Cream.Web, :view

  def render("index.json", %{contacts: contacts}) do
    %{data: render_many(contacts, "contact.json")}
  end

  def render("show.json", %{contact: contact}) do
    %{data: render_one(contact, "contact.json")}
  end

  def render("contact.json", %{contact: contact}) do
    %{
        id:         contact.id,
        first_name: contact.first_name,
        last_name:  contact.last_name,
        email:      contact.email
      }
  end
end
