defmodule PersonalSpaceWeb.PageController do
  use PersonalSpaceWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
