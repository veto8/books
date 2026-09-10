defmodule Reader.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Reader.Catalog` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        authors: "some authors",
        bookshelves: "some bookshelves",
        ext_no: 42,
        issued: ~D[2026-09-09],
        language: "some language",
        locc: "some locc",
        subjects: "some subjects",
        title: "some title",
        type: "some type"
      })
      |> Reader.Catalog.create_book()

    book
  end
end
