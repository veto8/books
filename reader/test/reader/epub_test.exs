defmodule Reader.EpubTest do
  use ExUnit.Case, async: true

  alias Reader.Epub

  describe "chapters/1" do
    test "parses spine documents into chapters, skipping cover and pg-header" do
      epub = fixture_epub()

      assert {:ok, chapters} = Epub.chapters(epub)
      assert length(chapters) == 2

      assert [%{title: "CHAPTER I.", paragraphs: [_ | _] = paras}, %{title: "CHAPTER II."}] =
               chapters

      assert Enum.join(paras, " ") =~ "stormy night"
    end

    test "falls back to a single untitled chapter when a document has no heading" do
      base = make_epub_dir()

      File.write!(
        Path.join(base, "OEBPS/ch1.html"),
        ~s(<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml"><body><p>Just prose.</p></body></html>)
      )

      epub = zip_epub(base)

      assert {:ok, [%{title: "Just prose.", paragraphs: ["Just prose."]}]} =
               Epub.chapters(epub)
    end

    test "returns {:error, :empty_epub} when no chapter documents exist" do
      base = make_epub_dir()

      File.write!(
        Path.join(base, "OEBPS/ch1.html"),
        ~s(<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml"><body><div id="pg-header">boilerplate</div></body></html>)
      )

      epub = zip_epub(base)

      assert {:error, :empty_epub} = Epub.chapters(epub)
    end

    test "returns an error for a non-zip binary" do
      assert {:error, _} = Epub.chapters("not a zip file at all")
    end
  end

  defp fixture_epub do
    base = make_epub_dir()

    File.write!(
      Path.join(base, "OEBPS/pg-header.html"),
      ~s(<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml"><body><div id="pg-header">boilerplate header</div></body></html>)
    )

    File.write!(
      Path.join(base, "OEBPS/ch1.html"),
      ~s(<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml"><body><h2>CHAPTER I.</h2><p>It was a dark and stormy night.</p><p>And so began.</p></body></html>)
    )

    File.write!(
      Path.join(base, "OEBPS/ch2.html"),
      ~s(<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml"><body><h2>CHAPTER II.</h2><p>Then it all ended.</p></body></html>)
    )

    File.write!(
      Path.join(base, "OEBPS/cover.html"),
      ~s(<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml"><body><h1>Cover</h1></body></html>)
    )

    zip_epub(base)
  end

  defp make_epub_dir do
    base = Path.join(System.tmp_dir!(), "reader_epub_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join(base, "META-INF"))
    File.mkdir_p!(Path.join(base, "OEBPS"))

    File.write!(
      Path.join(base, "META-INF/container.xml"),
      ~s(<?xml version="1.0" encoding="utf-8"?><container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0"><rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>)
    )

    File.write!(
      Path.join(base, "OEBPS/content.opf"),
      ~s(<?xml version="1.0" encoding="utf-8"?><package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="id"><manifest><item id="coverpage-wrapper" href="cover.html" media-type="application/xhtml+xml"/><item id="pg-header" href="pg-header.html" media-type="application/xhtml+xml"/><item id="ch1" href="ch1.html" media-type="application/xhtml+xml"/><item id="ch2" href="ch2.html" media-type="application/xhtml+xml"/></manifest><spine><itemref idref="coverpage-wrapper"/><itemref idref="pg-header"/><itemref idref="ch1"/><itemref idref="ch2"/></spine></package>)
    )

    base
  end

  defp zip_epub(base) do
    files =
      base
      |> Path.join("**/*")
      |> Path.wildcard()
      |> Enum.filter(&File.regular?/1)

    rel = Enum.map(files, &Path.relative_to(&1, base))

    {:ok, {_name, bin}} =
      File.cd!(base, fn ->
        :zip.create(~c"mini.epub", Enum.map(rel, &to_charlist/1), [:memory])
      end)

    File.rm_rf!(base)
    bin
  end
end
