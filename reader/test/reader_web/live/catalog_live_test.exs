defmodule ReaderWeb.CatalogLiveTest do
  use ReaderWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Reader.CatalogFixtures

  test "renders the catalog with results", %{conn: conn} do
    CatalogFixtures.book_fixture(%{
      ext_no: 2701,
      title: "Moby Dick",
      type: "Text",
      authors: "Herman Melville"
    })

    {:ok, view, html} = live(conn, ~p"/")

    assert html =~ "Project Gutenberg Catalog"
    assert has_element?(view, "#catalog-search")
    assert has_element?(view, "#books")
    assert html =~ "Moby Dick"
  end

  test "search refines results", %{conn: conn} do
    CatalogFixtures.book_fixture(%{ext_no: 1, title: "Paradise Lost", type: "Text"})
    CatalogFixtures.book_fixture(%{ext_no: 2, title: "Moby Dick", type: "Text"})

    conn = get(conn, ~p"/?q=Moby")
    {:ok, _view, html} = live(conn)

    assert html =~ "Moby Dick"
    refute html =~ "Paradise Lost"
  end
end
