defmodule Reader.CatalogTest do
  use Reader.DataCase

  alias Reader.Catalog

  describe "books" do
    alias Reader.Catalog.Book

    import Reader.CatalogFixtures

    @invalid_attrs %{
      type: nil,
      title: nil,
      language: nil,
      ext_no: nil,
      issued: nil,
      authors: nil,
      subjects: nil,
      locc: nil,
      bookshelves: nil
    }

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Catalog.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Catalog.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{
        type: "some type",
        title: "some title",
        language: "some language",
        ext_no: 42,
        issued: ~D[2026-09-09],
        authors: "some authors",
        subjects: "some subjects",
        locc: "some locc",
        bookshelves: "some bookshelves"
      }

      assert {:ok, %Book{} = book} = Catalog.create_book(valid_attrs)
      assert book.type == "some type"
      assert book.title == "some title"
      assert book.language == "some language"
      assert book.ext_no == 42
      assert book.issued == ~D[2026-09-09]
      assert book.authors == "some authors"
      assert book.subjects == "some subjects"
      assert book.locc == "some locc"
      assert book.bookshelves == "some bookshelves"
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()

      update_attrs = %{
        type: "some updated type",
        title: "some updated title",
        language: "some updated language",
        ext_no: 43,
        issued: ~D[2026-09-10],
        authors: "some updated authors",
        subjects: "some updated subjects",
        locc: "some updated locc",
        bookshelves: "some updated bookshelves"
      }

      assert {:ok, %Book{} = book} = Catalog.update_book(book, update_attrs)
      assert book.type == "some updated type"
      assert book.title == "some updated title"
      assert book.language == "some updated language"
      assert book.ext_no == 43
      assert book.issued == ~D[2026-09-10]
      assert book.authors == "some updated authors"
      assert book.subjects == "some updated subjects"
      assert book.locc == "some updated locc"
      assert book.bookshelves == "some updated bookshelves"
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_book(book, @invalid_attrs)
      assert book == Catalog.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Catalog.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Catalog.change_book(book)
    end
  end
end
