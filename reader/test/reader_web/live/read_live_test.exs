defmodule ReaderWeb.ReadLiveTest do
  use ReaderWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Reader.CatalogFixtures

  test "renders book metadata for Sound books without fetching text", %{conn: conn} do
    CatalogFixtures.book_fixture(%{ext_no: 3002, title: "A Cardinal Sin", type: "Sound"})

    {:ok, _view, html} = live(conn, ~p"/read/3002")

    assert html =~ "A Cardinal Sin"
    assert html =~ "Audio book"
    refute html =~ "Fetching the text"
  end
end
